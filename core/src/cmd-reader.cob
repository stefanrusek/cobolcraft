*> The string reader and the stock argument types of the command framework (docs/protocol/15a-
*> brigadier-command-library.md §1 the string reader, §5 argument types, §8 messages;
*> 15-commands-framework.md §4.2, §4.3). Reads BR-IN (core/copy/BRIGADIER.cpy): the argument starts at
*> BR-IN-CURSOR; on success the cursor is left after it, on a failure BR-E-KEY names the exception
*> (translation key of 15 §5.1, up to two string arguments, its cursor) and the caller discards the
*> reader.
*>
*> Entry points:
*>   BR-RAISE USING key (PIC X(48)), argument count, argument 1 (PIC X(64)) and length, argument 2 and
*>     length, cursor: records the exception in BR-ERR
*>   BR-ARG-PARSE USING node, integer value out (BINARY-DOUBLE: integer, long, bool), double value out
*>     (FLOAT-LONG: float, double), infinity flag out (BINARY-LONG: a float or double that parsed
*>     past the largest finite value, 15a §1.3)
*>   BR-NUMBER-TEXT USING kind (BR-P-FLOAT, -DOUBLE, -INTEGER or -LONG), integer, double, infinity
*>     flag, text out (PIC X(32)), length out: the number as Java prints it (15a §5: shortest digits
*>     that read back as the same value in the type's precision, plain decimal from 1e-3 to below 1e7,
*>     else d.dddE<exponent>; zero 0.0; Infinity)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RAISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-COUNT                BINARY-LONG.
 01 L-ARG1                 PIC X(64).
 01 L-LEN1                 BINARY-LONG.
 01 L-ARG2                 PIC X(64).
 01 L-LEN2                 BINARY-LONG.
 01 L-CURSOR               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-COUNT L-ARG1 L-LEN1 L-ARG2 L-LEN2 L-CURSOR.
     MOVE L-KEY TO BR-E-KEY
     MOVE L-COUNT TO BR-E-ARG-COUNT
     MOVE L-LEN1 TO BR-E-ARG-LENGTH(1)
     MOVE L-ARG1 TO BR-E-ARG(1)
     MOVE L-LEN2 TO BR-E-ARG-LENGTH(2)
     MOVE L-ARG2 TO BR-E-ARG(2)
     MOVE L-CURSOR TO BR-E-CURSOR
     GOBACK.
 END PROGRAM BR-RAISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RAISE-PLAIN.
*> USING key (PIC X(48)), cursor: an exception with no arguments.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-CURSOR               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CURSOR.
     MOVE L-KEY TO BR-E-KEY
     MOVE 0 TO BR-E-ARG-COUNT
     MOVE L-CURSOR TO BR-E-CURSOR
     GOBACK.
 END PROGRAM BR-RAISE-PLAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-NUMBER-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-A                   FLOAT-LONG.
 01 WS-A-BYTES REDEFINES WS-A PIC X(8).
 01 WS-M                   FLOAT-LONG.
 01 WS-CHECK               FLOAT-LONG.
 01 WS-CHECK-BYTES REDEFINES WS-CHECK PIC X(8).
 01 WS-SCALE               FLOAT-LONG.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SHORT-A             FLOAT-SHORT.
 01 WS-SHORT-A-BYTES REDEFINES WS-SHORT-A PIC X(4).
 01 WS-SHORT-C             FLOAT-SHORT.
 01 WS-SHORT-C-BYTES REDEFINES WS-SHORT-C PIC X(4).
 01 WS-DIGITS              PIC X(24).
 01 WS-DIGITS-LENGTH       BINARY-LONG.
 01 WS-INT-PART            BINARY-DOUBLE.
 01 WS-FRAC-PART           BINARY-DOUBLE.
 01 WS-DIV                 BINARY-DOUBLE.
 01 WS-EDIT                PIC -(19)9.
 01 WS-FRAC-TEXT           PIC X(20).
 01 WS-FRAC-LENGTH         BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NEGATIVE            BINARY-LONG.
 01 WS-MAX-DOUBLE          FLOAT-LONG VALUE 1.7976931348623157E308.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-TEXT                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-INT L-DOUBLE L-INF L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POS
     IF L-KIND = BR-P-INTEGER OR L-KIND = BR-P-LONG
         MOVE L-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     ELSE
         IF L-INF = 1
             IF L-DOUBLE < 0
                 STRING "-Infinity" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
             ELSE
                 STRING "Infinity" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
             END-IF
         ELSE
             PERFORM FORMAT-FLOATING
         END-IF
     END-IF
     COMPUTE L-LENGTH = WS-POS - 1
     GOBACK.

 FORMAT-FLOATING.
     MOVE 0 TO WS-NEGATIVE
     IF L-DOUBLE < 0
         MOVE 1 TO WS-NEGATIVE
         COMPUTE WS-A = 0 - L-DOUBLE
         STRING "-" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     ELSE
         MOVE L-DOUBLE TO WS-A
     END-IF
     IF WS-A = 0
         STRING "0.0" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     ELSE
         IF WS-A >= 0.001 AND WS-A < 10000000
             PERFORM FORMAT-PLAIN
         ELSE
             PERFORM FORMAT-SCIENTIFIC
         END-IF
     END-IF.

*> The least number of decimals k (1 to 15) with round(a * 10^k) / 10^k reading back as a, then the
*> digits with trailing zeros dropped (at least one decimal remains).
 FORMAT-PLAIN.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 15 OR WS-FOUND = 1
         COMPUTE WS-SCALE = 10 ** WS-K
         COMPUTE WS-R = FUNCTION INTEGER(WS-A * WS-SCALE + 0.5)
         COMPUTE WS-CHECK = WS-R / WS-SCALE
         PERFORM SAME-AS-A
     END-PERFORM
     SUBTRACT 1 FROM WS-K
     COMPUTE WS-DIV = 10 ** WS-K
     DIVIDE WS-R BY WS-DIV GIVING WS-INT-PART REMAINDER WS-FRAC-PART
     MOVE WS-INT-PART TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) "." DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     PERFORM EMIT-FRACTION.

*> WS-FOUND = 1 when WS-CHECK reads back as WS-A in the type's precision (float: single precision);
*> compared as bytes, because a floating comparison of the compiler has a tolerance.
 SAME-AS-A.
     IF L-KIND = BR-P-FLOAT
         MOVE WS-CHECK TO WS-SHORT-C
         MOVE WS-A TO WS-SHORT-A
         IF WS-SHORT-C-BYTES = WS-SHORT-A-BYTES
             MOVE 1 TO WS-FOUND
         END-IF
     ELSE
         IF WS-CHECK-BYTES = WS-A-BYTES
             MOVE 1 TO WS-FOUND
         END-IF
     END-IF.

*> The fraction WS-FRAC-PART of WS-K decimals, zero padded (K is the least that reads back, so the last
*> decimal is not 0 unless K = 1).
 EMIT-FRACTION.
     MOVE WS-FRAC-PART TO WS-EDIT
     MOVE ALL "0" TO WS-FRAC-TEXT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-FRAC-TEXT(WS-K - FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) + 1:)
     MOVE WS-K TO WS-FRAC-LENGTH
     STRING WS-FRAC-TEXT(1:WS-FRAC-LENGTH) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS.

*> d.ddd E exponent: the exponent e = floor(log10 a), the mantissa m = a / 10^e, then as the plain form.
 FORMAT-SCIENTIFIC.
     IF WS-A >= WS-MAX-DOUBLE
         STRING "1.7976931348623157E308" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     ELSE
         COMPUTE WS-E = FUNCTION INTEGER(FUNCTION LOG10(WS-A))
         COMPUTE WS-SCALE = 10 ** WS-E
         COMPUTE WS-M = WS-A / WS-SCALE
         COMPUTE WS-E2 = FUNCTION INTEGER(FUNCTION LOG10(WS-M))
         ADD WS-E2 TO WS-E
         COMPUTE WS-SCALE = 10 ** WS-E
         COMPUTE WS-M = WS-A / WS-SCALE
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16 OR WS-FOUND = 1
             COMPUTE WS-R = FUNCTION INTEGER(WS-M * 10 ** WS-K + 0.5)
             COMPUTE WS-CHECK = WS-R / 10 ** WS-K * WS-SCALE
             PERFORM SAME-AS-A
         END-PERFORM
         SUBTRACT 1 FROM WS-K
         COMPUTE WS-DIV = 10 ** WS-K
         DIVIDE WS-R BY WS-DIV GIVING WS-INT-PART REMAINDER WS-FRAC-PART
         IF WS-INT-PART >= 10
             MOVE 1 TO WS-INT-PART
             MOVE 0 TO WS-FRAC-PART
             ADD 1 TO WS-E
         END-IF
         MOVE WS-INT-PART TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) "." DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
         PERFORM EMIT-FRACTION
         MOVE WS-E TO WS-EDIT
         STRING "E" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
     END-IF.
 END PROGRAM BR-NUMBER-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-PARSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-QUOTE               PIC X.
 01 WS-ESCAPED             BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-RUN-LENGTH          BINARY-LONG.
 01 WS-RUN                 PIC X(1024).
 01 WS-VALID               BINARY-LONG.
 01 WS-IS-UNQUOTED         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-NEGATIVE            BINARY-LONG.
 01 WS-DIGITS-COUNT        BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-SIGNIFICANT         PIC X(24).
 01 WS-SIG-LENGTH          BINARY-LONG.
 01 WS-LIMIT               PIC X(24).
 01 WS-ACC                 BINARY-DOUBLE.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG.
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-NUMBER-TEXT         PIC X(32).
 01 WS-SHORT               FLOAT-SHORT.
 01 WS-MIN-I               BINARY-DOUBLE.
 01 WS-MAX-I               BINARY-DOUBLE.
 01 WS-MIN-D               FLOAT-LONG.
 01 WS-MAX-D               FLOAT-LONG.
 01 WS-MAX-FLOAT           FLOAT-LONG VALUE 3.4028234663852886E38.
 01 WS-MAX-DOUBLE          FLOAT-LONG VALUE 1.7976931348623157E308.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DIGIT-RUN           BINARY-LONG.
 01 WS-HEAD                PIC X(40).
 01 WS-EXPONENT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-INT L-DOUBLE L-INF.
     MOVE 0 TO L-INT L-DOUBLE L-INF
     MOVE SPACES TO BR-E-KEY
     MOVE BR-IN-CURSOR TO WS-START
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-BOOL
             PERFORM DO-BOOL
         WHEN BR-P-FLOAT
             PERFORM DO-NUMBER
         WHEN BR-P-DOUBLE
             PERFORM DO-NUMBER
         WHEN BR-P-INTEGER
             PERFORM DO-NUMBER
         WHEN BR-P-LONG
             PERFORM DO-NUMBER
         WHEN BR-P-STRING
             PERFORM DO-STRING
         WHEN OTHER
             MOVE WS-START TO WS-C
             PERFORM UNTIL WS-C >= BR-IN-LENGTH OR BR-IN-TEXT(WS-C + 1:1) = SPACE
                 ADD 1 TO WS-C
             END-PERFORM
             MOVE WS-C TO BR-IN-CURSOR
     END-EVALUATE
     GOBACK.

*> ---- raising ------------------------------------------------------------------------------
 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 RAISE-RUN.
*> an exception with the run text (WS-RUN) as its one argument, at cursor WS-RC
     MOVE 1 TO WS-N-ARGS
     MOVE WS-RUN(1:WS-RUN-LENGTH) TO WS-A1
     MOVE WS-RUN-LENGTH TO WS-L1
     IF WS-L1 > 64
         MOVE 64 TO WS-L1
     END-IF
     PERFORM RAISE-NOW.

*> ---- the character classes of 15a §1.2 --------------------------------------------------------
 TEST-UNQUOTED.
     MOVE 0 TO WS-IS-UNQUOTED
     IF (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "A" AND WS-CH <= "Z")
             OR (WS-CH >= "a" AND WS-CH <= "z") OR WS-CH = "_" OR WS-CH = "-" OR WS-CH = "."
             OR WS-CH = "+"
         MOVE 1 TO WS-IS-UNQUOTED
     END-IF.

*> ---- readString / readUnquotedString / readStringUntil (15a §1.4) -------------------------------
*> From WS-C; the value in WS-STR (WS-STR-LENGTH); a failure sets BR-E-KEY.
 READ-STRING.
     MOVE 0 TO WS-STR-LENGTH
     MOVE SPACES TO WS-STR
     IF WS-C < BR-IN-LENGTH
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         IF WS-CH = '"' OR WS-CH = "'"
             MOVE WS-CH TO WS-QUOTE
             ADD 1 TO WS-C
             PERFORM READ-UNTIL-QUOTE
         ELSE
             PERFORM READ-UNQUOTED
         END-IF
     END-IF.

 READ-UNQUOTED.
     MOVE 1 TO WS-IS-UNQUOTED
     PERFORM UNTIL WS-C >= BR-IN-LENGTH OR WS-IS-UNQUOTED = 0
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         PERFORM TEST-UNQUOTED
         IF WS-IS-UNQUOTED = 1
             ADD 1 TO WS-STR-LENGTH
             MOVE WS-CH TO WS-STR(WS-STR-LENGTH:1)
             ADD 1 TO WS-C
         END-IF
     END-PERFORM.

 READ-UNTIL-QUOTE.
     MOVE 0 TO WS-ESCAPED WS-DONE
     PERFORM UNTIL WS-DONE = 1
         IF WS-C >= BR-IN-LENGTH
             MOVE "parsing.quote.expected.end" TO WS-KEY
             MOVE 0 TO WS-N-ARGS
             MOVE BR-IN-LENGTH TO WS-RC
             PERFORM RAISE-NOW
             MOVE 1 TO WS-DONE
         ELSE
             MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
             EVALUATE TRUE
                 WHEN WS-ESCAPED = 1 AND (WS-CH = WS-QUOTE OR WS-CH = "\")
                     ADD 1 TO WS-STR-LENGTH
                     MOVE WS-CH TO WS-STR(WS-STR-LENGTH:1)
                     MOVE 0 TO WS-ESCAPED
                     ADD 1 TO WS-C
                 WHEN WS-ESCAPED = 1
                     MOVE "parsing.quote.escape" TO WS-KEY
                     MOVE 1 TO WS-N-ARGS
                     MOVE WS-CH TO WS-A1
                     MOVE 1 TO WS-L1
                     MOVE WS-C TO WS-RC
                     PERFORM RAISE-NOW
                     MOVE 1 TO WS-DONE
                 WHEN WS-CH = "\"
                     MOVE 1 TO WS-ESCAPED
                     ADD 1 TO WS-C
                 WHEN WS-CH = WS-QUOTE
                     ADD 1 TO WS-C
                     MOVE 1 TO WS-DONE
                 WHEN OTHER
                     ADD 1 TO WS-STR-LENGTH
                     MOVE WS-CH TO WS-STR(WS-STR-LENGTH:1)
                     ADD 1 TO WS-C
             END-EVALUATE
         END-IF
     END-PERFORM.

 DO-STRING.
     MOVE WS-START TO WS-C
     EVALUATE BR-N-STRING-KIND(L-NODE)
         WHEN BR-S-GREEDY
             MOVE BR-IN-LENGTH TO WS-C
         WHEN BR-S-PHRASE
             PERFORM READ-STRING
         WHEN OTHER
             PERFORM READ-UNQUOTED
     END-EVALUATE
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
     END-IF.

*> ---- readBoolean (15a §1.4: through readString) ---------------------------------------------
 DO-BOOL.
     MOVE WS-START TO WS-C
     PERFORM READ-STRING
     IF BR-E-KEY = SPACES
         EVALUATE TRUE
             WHEN WS-STR-LENGTH = 0
                 MOVE "parsing.bool.expected" TO WS-KEY
                 MOVE 0 TO WS-N-ARGS
                 MOVE WS-C TO WS-RC
                 PERFORM RAISE-NOW
             WHEN WS-STR(1:WS-STR-LENGTH) = "true" AND WS-STR-LENGTH = 4
                 MOVE 1 TO L-INT
                 MOVE WS-C TO BR-IN-CURSOR
             WHEN WS-STR(1:WS-STR-LENGTH) = "false" AND WS-STR-LENGTH = 5
                 MOVE 0 TO L-INT
                 MOVE WS-C TO BR-IN-CURSOR
             WHEN OTHER
                 MOVE "parsing.bool.invalid" TO WS-KEY
                 MOVE 1 TO WS-N-ARGS
                 MOVE WS-STR(1:WS-STR-LENGTH) TO WS-A1
                 MOVE WS-STR-LENGTH TO WS-L1
                 IF WS-L1 > 64
                     MOVE 64 TO WS-L1
                 END-IF
                 MOVE WS-START TO WS-RC
                 PERFORM RAISE-NOW
         END-EVALUATE
     END-IF.

*> ---- readInt, readLong, readFloat, readDouble and the range check (15a §1.3, §5) -------------
 DO-NUMBER.
     MOVE BR-N-TYPE(L-NODE) TO WS-KIND
     MOVE WS-START TO WS-C
     PERFORM UNTIL WS-C >= BR-IN-LENGTH
         MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
         IF (WS-CH >= "0" AND WS-CH <= "9") OR WS-CH = "." OR WS-CH = "-"
             ADD 1 TO WS-C
         ELSE
             EXIT PERFORM
         END-IF
     END-PERFORM
     COMPUTE WS-RUN-LENGTH = WS-C - WS-START
     MOVE SPACES TO WS-RUN
     IF WS-RUN-LENGTH = 0
         PERFORM RAISE-NUMBER-EXPECTED
     ELSE
         MOVE BR-IN-TEXT(WS-START + 1:WS-RUN-LENGTH) TO WS-RUN
         PERFORM VALIDATE-RUN
         IF WS-VALID = 0
             PERFORM RAISE-NUMBER-INVALID
         ELSE
             IF WS-KIND = BR-P-INTEGER OR WS-KIND = BR-P-LONG
                 PERFORM CONVERT-INTEGER
             ELSE
                 PERFORM CONVERT-DOUBLE
             END-IF
             IF WS-VALID = 0
                 PERFORM RAISE-NUMBER-INVALID
             ELSE
                 PERFORM RANGE-CHECK
                 IF BR-E-KEY = SPACES
                     MOVE WS-C TO BR-IN-CURSOR
                 END-IF
             END-IF
         END-IF
     END-IF.

 RAISE-NUMBER-EXPECTED.
     EVALUATE WS-KIND
         WHEN BR-P-INTEGER
             MOVE "parsing.int.expected" TO WS-KEY
         WHEN BR-P-LONG
             MOVE "parsing.long.expected" TO WS-KEY
         WHEN BR-P-FLOAT
             MOVE "parsing.float.expected" TO WS-KEY
         WHEN OTHER
             MOVE "parsing.double.expected" TO WS-KEY
     END-EVALUATE
     MOVE 0 TO WS-N-ARGS
     MOVE WS-START TO WS-RC
     PERFORM RAISE-NOW.

 RAISE-NUMBER-INVALID.
     EVALUATE WS-KIND
         WHEN BR-P-INTEGER
             MOVE "parsing.int.invalid" TO WS-KEY
         WHEN BR-P-LONG
             MOVE "parsing.long.invalid" TO WS-KEY
         WHEN BR-P-FLOAT
             MOVE "parsing.float.invalid" TO WS-KEY
         WHEN OTHER
             MOVE "parsing.double.invalid" TO WS-KEY
     END-EVALUATE
     MOVE WS-START TO WS-RC
     PERFORM RAISE-RUN.

*> The grammar the Java parsers accept on a run of 0-9 . - (15a §1.3): an optional leading -, then
*> digits only (integer, long) or digits with at most one dot (float, double), at least one digit.
 VALIDATE-RUN.
     MOVE 1 TO WS-VALID
     MOVE 0 TO WS-DIGITS-COUNT WS-DOTS
     MOVE 1 TO WS-FIRST
     IF WS-RUN(1:1) = "-"
         MOVE 2 TO WS-FIRST
     END-IF
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-RUN-LENGTH
         EVALUATE TRUE
             WHEN WS-RUN(WS-I:1) = "."
                 ADD 1 TO WS-DOTS
             WHEN WS-RUN(WS-I:1) = "-"
                 MOVE 0 TO WS-VALID
             WHEN OTHER
                 ADD 1 TO WS-DIGITS-COUNT
         END-EVALUATE
     END-PERFORM
     IF WS-DIGITS-COUNT = 0
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-DOTS > 1
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-DOTS = 1 AND (WS-KIND = BR-P-INTEGER OR WS-KIND = BR-P-LONG)
         MOVE 0 TO WS-VALID
     END-IF.

*> The value of an integer or long run (valid grammar): at most 10 or 19 significant digits and within
*> the signed range; accumulated negative so that the lowest value fits.
 CONVERT-INTEGER.
     MOVE 0 TO WS-NEGATIVE
     IF WS-RUN(1:1) = "-"
         MOVE 1 TO WS-NEGATIVE
     END-IF
     COMPUTE WS-I = WS-NEGATIVE + 1
     PERFORM UNTIL WS-I >= WS-RUN-LENGTH OR WS-RUN(WS-I:1) NOT = "0"
         ADD 1 TO WS-I
     END-PERFORM
     COMPUTE WS-SIG-LENGTH = WS-RUN-LENGTH - WS-I + 1
     MOVE SPACES TO WS-SIGNIFICANT
     IF WS-SIG-LENGTH <= 19
         MOVE WS-RUN(WS-I:WS-SIG-LENGTH) TO WS-SIGNIFICANT
     END-IF
     MOVE 1 TO WS-VALID
     IF WS-KIND = BR-P-INTEGER
         IF WS-SIG-LENGTH > 10
             MOVE 0 TO WS-VALID
         END-IF
         IF WS-SIG-LENGTH = 10
             MOVE "2147483647" TO WS-LIMIT
             IF WS-NEGATIVE = 1
                 MOVE "2147483648" TO WS-LIMIT
             END-IF
             IF WS-SIGNIFICANT(1:10) > WS-LIMIT(1:10)
                 MOVE 0 TO WS-VALID
             END-IF
         END-IF
     ELSE
         IF WS-SIG-LENGTH > 19
             MOVE 0 TO WS-VALID
         END-IF
         IF WS-SIG-LENGTH = 19
             MOVE "9223372036854775807" TO WS-LIMIT
             IF WS-NEGATIVE = 1
                 MOVE "9223372036854775808" TO WS-LIMIT
             END-IF
             IF WS-SIGNIFICANT(1:19) > WS-LIMIT(1:19)
                 MOVE 0 TO WS-VALID
             END-IF
         END-IF
     END-IF
     IF WS-VALID = 1
         MOVE 0 TO WS-ACC
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SIG-LENGTH
             COMPUTE WS-DIGIT = FUNCTION ORD(WS-SIGNIFICANT(WS-I:1)) - FUNCTION ORD("0")
             COMPUTE WS-ACC = WS-ACC * 10 - WS-DIGIT
         END-PERFORM
         IF WS-NEGATIVE = 0
             COMPUTE L-INT = 0 - WS-ACC
         ELSE
             MOVE WS-ACC TO L-INT
         END-IF
     END-IF.

*> A float or double run: NUMVAL up to 30 integer digits, a longer integer part is scaled by a power
*> of ten; beyond the largest finite value the value is infinity (L-INF = 1, 15a §1.3). A float is
*> rounded to single precision.
 CONVERT-DOUBLE.
     MOVE 1 TO WS-VALID
     MOVE 0 TO WS-EXPONENT
     COMPUTE WS-I = WS-RUN-LENGTH
     MOVE 1 TO WS-FIRST
     IF WS-RUN(1:1) = "-"
         MOVE 2 TO WS-FIRST
     END-IF
     MOVE 0 TO WS-DIGIT-RUN
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-RUN-LENGTH OR WS-RUN(WS-I:1) = "."
         ADD 1 TO WS-DIGIT-RUN
     END-PERFORM
     IF WS-DIGIT-RUN > 30
         COMPUTE WS-EXPONENT = WS-DIGIT-RUN - 30
         MOVE SPACES TO WS-HEAD
         COMPUTE WS-C = WS-FIRST + 29
         MOVE WS-RUN(1:WS-C) TO WS-HEAD
         COMPUTE WS-DOUBLE = FUNCTION NUMVAL(WS-HEAD)
         IF WS-DIGIT-RUN > 308
             MOVE 1 TO WS-INF
         ELSE
             MOVE 0 TO WS-INF
             COMPUTE WS-DOUBLE = WS-DOUBLE * 10 ** WS-EXPONENT
         END-IF
         COMPUTE WS-C = WS-START + WS-RUN-LENGTH
     ELSE
         MOVE 0 TO WS-INF
         COMPUTE WS-DOUBLE = FUNCTION NUMVAL(WS-RUN(1:WS-RUN-LENGTH))
     END-IF
     IF WS-KIND = BR-P-FLOAT AND WS-INF = 0
         IF WS-DOUBLE > WS-MAX-FLOAT * 1.0000000001 OR WS-DOUBLE < 0 - WS-MAX-FLOAT * 1.0000000001
             MOVE 1 TO WS-INF
         ELSE
             MOVE WS-DOUBLE TO WS-SHORT
             MOVE WS-SHORT TO WS-DOUBLE
         END-IF
     END-IF
     MOVE WS-DOUBLE TO L-DOUBLE
     MOVE WS-INF TO L-INF.

*> After the value: below the minimum or above the maximum resets the cursor to the start of the
*> argument and raises the low or high exception with (limit, found) (15a §5; the game text puts the
*> limit first). Defaults: the 32 or 64 bit limits, plus or minus the largest finite float or double.
 RANGE-CHECK.
     MOVE 0 TO WS-LOW WS-HIGH
     IF WS-KIND = BR-P-INTEGER OR WS-KIND = BR-P-LONG
         IF WS-KIND = BR-P-INTEGER
             MOVE -2147483648 TO WS-MIN-I
             MOVE 2147483647 TO WS-MAX-I
         ELSE
             COMPUTE WS-MIN-I = -9223372036854775807 - 1
             MOVE 9223372036854775807 TO WS-MAX-I
         END-IF
         IF BR-N-HAS-MIN(L-NODE) = 1
             MOVE BR-N-IMIN(L-NODE) TO WS-MIN-I
         END-IF
         IF BR-N-HAS-MAX(L-NODE) = 1
             MOVE BR-N-IMAX(L-NODE) TO WS-MAX-I
         END-IF
         IF L-INT < WS-MIN-I
             MOVE 1 TO WS-LOW
         END-IF
         IF L-INT > WS-MAX-I
             MOVE 1 TO WS-HIGH
         END-IF
     ELSE
         IF WS-KIND = BR-P-FLOAT
             COMPUTE WS-MAX-D = WS-MAX-FLOAT
         ELSE
             COMPUTE WS-MAX-D = WS-MAX-DOUBLE
         END-IF
         COMPUTE WS-MIN-D = 0 - WS-MAX-D
         IF BR-N-HAS-MIN(L-NODE) = 1
             MOVE BR-N-DMIN(L-NODE) TO WS-MIN-D
         END-IF
         IF BR-N-HAS-MAX(L-NODE) = 1
             MOVE BR-N-DMAX(L-NODE) TO WS-MAX-D
         END-IF
         IF L-INF = 1 AND L-DOUBLE > 0
             MOVE 1 TO WS-HIGH
         END-IF
         IF L-INF = 1 AND L-DOUBLE < 0
             MOVE 1 TO WS-LOW
         END-IF
         IF L-INF = 0 AND L-DOUBLE < WS-MIN-D
             MOVE 1 TO WS-LOW
         END-IF
         IF L-INF = 0 AND L-DOUBLE > WS-MAX-D
             MOVE 1 TO WS-HIGH
         END-IF
     END-IF
     IF WS-LOW = 1 OR WS-HIGH = 1
         PERFORM RAISE-RANGE
     END-IF.

 RAISE-RANGE.
     EVALUATE TRUE
         WHEN WS-KIND = BR-P-INTEGER AND WS-LOW = 1
             MOVE "argument.integer.low" TO WS-KEY
         WHEN WS-KIND = BR-P-INTEGER
             MOVE "argument.integer.big" TO WS-KEY
         WHEN WS-KIND = BR-P-LONG AND WS-LOW = 1
             MOVE "argument.long.low" TO WS-KEY
         WHEN WS-KIND = BR-P-LONG
             MOVE "argument.long.big" TO WS-KEY
         WHEN WS-KIND = BR-P-FLOAT AND WS-LOW = 1
             MOVE "argument.float.low" TO WS-KEY
         WHEN WS-KIND = BR-P-FLOAT
             MOVE "argument.float.big" TO WS-KEY
         WHEN WS-LOW = 1
             MOVE "argument.double.low" TO WS-KEY
         WHEN OTHER
             MOVE "argument.double.big" TO WS-KEY
     END-EVALUATE
     MOVE 2 TO WS-N-ARGS
     MOVE WS-START TO WS-RC
     MOVE 0 TO WS-INF
     IF WS-LOW = 1
         CALL "BR-NUMBER-TEXT" USING WS-KIND WS-MIN-I WS-MIN-D WS-INF WS-NUMBER-TEXT WS-L1
     ELSE
         CALL "BR-NUMBER-TEXT" USING WS-KIND WS-MAX-I WS-MAX-D WS-INF WS-NUMBER-TEXT WS-L1
     END-IF
     MOVE WS-NUMBER-TEXT TO WS-A1
     CALL "BR-NUMBER-TEXT" USING WS-KIND L-INT L-DOUBLE L-INF WS-NUMBER-TEXT WS-L2
     MOVE WS-NUMBER-TEXT TO WS-A2
     PERFORM RAISE-NOW.
 END PROGRAM BR-ARG-PARSE.
