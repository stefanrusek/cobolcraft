*> The SNBT value grammar of docs/protocol/15-commands-framework.md §9.4 as a recogniser: the argument types nbt_compound_tag,
*> nbt_tag, component, style and the values inside block states, item components and selector options end where the
*> SNBT value ends. Reads BR-IN from BR-IN-CURSOR (core/copy/BRIGADIER.cpy); on success the cursor is after the value, on a
*> failure BR-E-KEY names the exception. The exact exception the library reports for a structural failure (a missing key,
*> colon, comma or bracket) was not traced (15 §9.4 open question 5), so BR-SNBT-VALUE reports argument.nbt.expected.key,
*> argument.nbt.expected.value, parsing.expected '<char>' and argument.nbt.trailing; the value rules are those of the table.
*>
*> Entry points:
*>   BR-SNBT-VALUE USING kind out (BINARY-LONG: 1 compound, 2 list, 3 array, 4 string, 5 integer, 6 floating point,
*>     7 boolean): one value (nested compounds, lists and arrays recursively); whitespace is allowed around the tokens inside
*>     brackets
*>   BR-SNBT-SKIP-SPACES: moves the cursor over spaces
*>   BR-SNBT-STRING USING cursor in/out, text out (PIC X(1024)), length out: a quoted string with the escapes of the table (\\ \"
*>     \' \b \f \n \r \s \t \xHH \uHHHH \UHHHHHHHH) or an unquoted run of a-z A-Z 0-9 _ - . + (a quoted string is returned
*>     without its quotes and with the escapes applied as UTF-8)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SNBT-SKIP-SPACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 PROCEDURE DIVISION.
     PERFORM UNTIL BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
         ADD 1 TO BR-IN-CURSOR
     END-PERFORM
     GOBACK.
 END PROGRAM BR-SNBT-SKIP-SPACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SNBT-STRING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-CH                  PIC X.
 01 WS-QUOTE               PIC X.
 01 WS-DONE                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-RC                  BINARY-LONG.
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CURSOR               BINARY-LONG.
 01 L-STR                  PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-CURSOR L-STR L-LENGTH.
     MOVE 0 TO L-LENGTH
     MOVE SPACES TO L-STR
     IF L-CURSOR < BR-IN-LENGTH AND (BR-IN-TEXT(L-CURSOR + 1:1) = '"' OR BR-IN-TEXT(L-CURSOR + 1:1) = "'")
         MOVE BR-IN-TEXT(L-CURSOR + 1:1) TO WS-QUOTE
         ADD 1 TO L-CURSOR
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             IF L-CURSOR >= BR-IN-LENGTH
                 MOVE "parsing.quote.expected.end" TO WS-KEY
                 MOVE BR-IN-LENGTH TO WS-RC
                 PERFORM RAISE-NOW
                 MOVE 1 TO WS-DONE
             ELSE
                 MOVE BR-IN-TEXT(L-CURSOR + 1:1) TO WS-CH
                 ADD 1 TO L-CURSOR
                 EVALUATE TRUE
                     WHEN WS-CH = WS-QUOTE
                         MOVE 1 TO WS-DONE
                     WHEN WS-CH = "\"
                         PERFORM DO-ESCAPE
                     WHEN OTHER
                         ADD 1 TO L-LENGTH
                         MOVE WS-CH TO L-STR(L-LENGTH:1)
                 END-EVALUATE
             END-IF
         END-PERFORM
     ELSE
         PERFORM UNTIL L-CURSOR >= BR-IN-LENGTH
             MOVE BR-IN-TEXT(L-CURSOR + 1:1) TO WS-CH
             IF (WS-CH >= "0" AND WS-CH <= "9") OR (WS-CH >= "A" AND WS-CH <= "Z")
                     OR (WS-CH >= "a" AND WS-CH <= "z") OR WS-CH = "_" OR WS-CH = "-" OR WS-CH = "."
                     OR WS-CH = "+"
                 ADD 1 TO L-LENGTH
                 MOVE WS-CH TO L-STR(L-LENGTH:1)
                 ADD 1 TO L-CURSOR
             ELSE
                 EXIT PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.

*> After a backslash: the character (cursor after it). \\ \" \' keep the character; b f n r s t map to control
*> characters; x u U read 2, 4 or 8 hexadecimal digits as a code point (ASCII only is stored as itself, others as ?).
 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 DO-ESCAPE.
     IF L-CURSOR >= BR-IN-LENGTH
         MOVE "snbt.parser.invalid_string_contents" TO WS-KEY
         MOVE BR-IN-LENGTH TO WS-RC
         PERFORM RAISE-NOW
         MOVE 1 TO WS-DONE
     ELSE
         MOVE BR-IN-TEXT(L-CURSOR + 1:1) TO WS-CH
         ADD 1 TO L-CURSOR
         MOVE 0 TO WS-DIGITS
         EVALUATE WS-CH
             WHEN "\"
             WHEN '"'
             WHEN "'"
                 ADD 1 TO L-LENGTH
                 MOVE WS-CH TO L-STR(L-LENGTH:1)
             WHEN "b"
                 ADD 1 TO L-LENGTH
                 MOVE X"08" TO L-STR(L-LENGTH:1)
             WHEN "f"
                 ADD 1 TO L-LENGTH
                 MOVE X"0C" TO L-STR(L-LENGTH:1)
             WHEN "n"
                 ADD 1 TO L-LENGTH
                 MOVE X"0A" TO L-STR(L-LENGTH:1)
             WHEN "r"
                 ADD 1 TO L-LENGTH
                 MOVE X"0D" TO L-STR(L-LENGTH:1)
             WHEN "s"
                 ADD 1 TO L-LENGTH
                 MOVE SPACE TO L-STR(L-LENGTH:1)
             WHEN "t"
                 ADD 1 TO L-LENGTH
                 MOVE X"09" TO L-STR(L-LENGTH:1)
             WHEN "x"
                 MOVE 2 TO WS-DIGITS
             WHEN "u"
                 MOVE 4 TO WS-DIGITS
             WHEN "U"
                 MOVE 8 TO WS-DIGITS
             WHEN OTHER
                 MOVE "snbt.parser.invalid_string_contents" TO WS-KEY
                 COMPUTE WS-RC = L-CURSOR - 1
                 PERFORM RAISE-NOW
                 MOVE 1 TO WS-DONE
         END-EVALUATE
         IF WS-DIGITS > 0
             PERFORM HEX-ESCAPE
         END-IF
     END-IF.

 HEX-ESCAPE.
     MOVE 0 TO WS-CODE
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-DIGITS OR WS-OK = 0
         IF L-CURSOR >= BR-IN-LENGTH
             MOVE 0 TO WS-OK
         ELSE
             MOVE BR-IN-TEXT(L-CURSOR + 1:1) TO WS-CH
             EVALUATE TRUE
                 WHEN WS-CH >= "0" AND WS-CH <= "9"
                     COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("0")
                 WHEN WS-CH >= "a" AND WS-CH <= "f"
                     COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("a") + 10
                 WHEN WS-CH >= "A" AND WS-CH <= "F"
                     COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("A") + 10
                 WHEN OTHER
                     MOVE 0 TO WS-OK
             END-EVALUATE
             IF WS-OK = 1
                 COMPUTE WS-CODE = WS-CODE * 16 + WS-DIGIT
                 ADD 1 TO L-CURSOR
             END-IF
         END-IF
     END-PERFORM
     IF WS-OK = 1
         ADD 1 TO L-LENGTH
         IF WS-CODE < 128
             MOVE FUNCTION CHAR(WS-CODE + 1) TO L-STR(L-LENGTH:1)
         ELSE
             MOVE "?" TO L-STR(L-LENGTH:1)
         END-IF
     ELSE
         MOVE "snbt.parser.expected_hex_escape" TO WS-KEY
         MOVE L-CURSOR TO WS-RC
         PERFORM RAISE-NOW
         MOVE 1 TO WS-DONE
     END-IF.
 END PROGRAM BR-SNBT-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SNBT-VALUE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 LOCAL-STORAGE SECTION.
 01 LS-N-ARGS              BINARY-LONG.
 01 LS-L2                  BINARY-LONG.
 01 LS-CH                  PIC X.
 01 LS-START               BINARY-LONG.
 01 LS-C                   BINARY-LONG.
 01 LS-KEY                 PIC X(48).
 01 LS-REASON              PIC X(48).
 01 LS-A1                  PIC X(64).
 01 LS-A2                  PIC X(64).
 01 LS-L1                  BINARY-LONG.
 01 LS-RC                  BINARY-LONG.
 01 LS-STR                 PIC X(1024).
 01 LS-STR-LENGTH          BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-PREFIX              PIC X.
 01 LS-DIGITS              BINARY-LONG.
 01 LS-IS-FLOAT            BINARY-LONG.
 01 LS-BASE                BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-LEAD-ZERO           BINARY-LONG.
 01 LS-WORD-END            BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND.
     GO TO MAIN-LINE.

 RAISE-PLAIN.
     MOVE 0 TO LS-N-ARGS LS-L1 LS-L2
     CALL "BR-RAISE" USING LS-KEY LS-N-ARGS LS-A1 LS-L1 LS-A2 LS-L2 LS-RC.

*> parsing.expected with the character LS-CH at the cursor.
 RAISE-EXPECTED.
     MOVE "parsing.expected" TO LS-KEY
     MOVE LS-CH TO LS-A1
     MOVE 1 TO LS-L1
     MOVE BR-IN-CURSOR TO LS-RC
     MOVE 1 TO LS-N-ARGS
     MOVE 0 TO LS-L2
     CALL "BR-RAISE" USING LS-KEY LS-N-ARGS LS-A1 LS-L1 LS-A2 LS-L2 LS-RC.

 UNQUOTED-CHAR.
     MOVE 0 TO LS-OK
     IF (LS-CH >= "0" AND LS-CH <= "9") OR (LS-CH >= "A" AND LS-CH <= "Z")
             OR (LS-CH >= "a" AND LS-CH <= "z") OR LS-CH = "_" OR LS-CH = "-" OR LS-CH = "."
             OR LS-CH = "+"
         MOVE 1 TO LS-OK
     END-IF.

*> ---- compound: { key : value , ... } ------------------------------------------------------------------
 DO-COMPOUND.
     MOVE 1 TO L-KIND
     ADD 1 TO BR-IN-CURSOR
     CALL "BR-SNBT-SKIP-SPACES"
     MOVE 0 TO LS-DONE
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
         ADD 1 TO BR-IN-CURSOR
         MOVE 1 TO LS-DONE
     END-IF
     PERFORM UNTIL LS-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM COMPOUND-ENTRY
         IF BR-E-KEY = SPACES
             PERFORM COMPOUND-NEXT
         END-IF
     END-PERFORM.

 COMPOUND-ENTRY.
     MOVE BR-IN-CURSOR TO LS-START
     CALL "BR-SNBT-STRING" USING BR-IN-CURSOR LS-STR LS-STR-LENGTH
     IF BR-E-KEY = SPACES
         EVALUATE TRUE
             WHEN BR-IN-CURSOR = LS-START
                 MOVE "argument.nbt.expected.key" TO LS-KEY
                 MOVE LS-START TO LS-RC
                 PERFORM RAISE-PLAIN
             WHEN LS-STR-LENGTH = 0
                 MOVE "snbt.parser.empty_key" TO LS-KEY
                 MOVE LS-START TO LS-RC
                 PERFORM RAISE-PLAIN
             WHEN OTHER
                 CALL "BR-SNBT-SKIP-SPACES"
                 IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ":"
                     ADD 1 TO BR-IN-CURSOR
                     CALL "BR-SNBT-SKIP-SPACES"
                     CALL "BR-SNBT-VALUE" USING LS-SUB
                     CALL "BR-SNBT-SKIP-SPACES"
                 ELSE
                     MOVE ":" TO LS-CH
                     PERFORM RAISE-EXPECTED
                 END-IF
         END-EVALUATE
     END-IF.

*> After an entry: a comma and the next entry (a comma before the closing brace is not accepted), or the closing brace.
 COMPOUND-NEXT.
     EVALUATE TRUE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO LS-DONE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
             ADD 1 TO BR-IN-CURSOR
             CALL "BR-SNBT-SKIP-SPACES"
         WHEN OTHER
             MOVE "}" TO LS-CH
             PERFORM RAISE-EXPECTED
     END-EVALUATE.

*> ---- list and arrays: [ v , ... ]   [B; ...]  [I; ...]  [L; ...] -------------------------------------------
 DO-LIST.
     MOVE 2 TO L-KIND
     ADD 1 TO BR-IN-CURSOR
     MOVE SPACE TO LS-PREFIX
     IF BR-IN-CURSOR + 1 < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 2:1) = ";"
             AND (BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "B" OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "I"
                 OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "L")
         MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO LS-PREFIX
         MOVE 3 TO L-KIND
         ADD 2 TO BR-IN-CURSOR
     END-IF
     CALL "BR-SNBT-SKIP-SPACES"
     MOVE 0 TO LS-DONE
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
         ADD 1 TO BR-IN-CURSOR
         MOVE 1 TO LS-DONE
     END-IF
     PERFORM UNTIL LS-DONE = 1 OR BR-E-KEY NOT = SPACES
         MOVE BR-IN-CURSOR TO LS-START
         CALL "BR-SNBT-VALUE" USING LS-SUB
         IF BR-E-KEY = SPACES AND LS-PREFIX NOT = SPACE
             PERFORM CHECK-ARRAY-ELEMENT
         END-IF
         IF BR-E-KEY = SPACES
             CALL "BR-SNBT-SKIP-SPACES"
             EVALUATE TRUE
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
                     ADD 1 TO BR-IN-CURSOR
                     MOVE 1 TO LS-DONE
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                     ADD 1 TO BR-IN-CURSOR
                     CALL "BR-SNBT-SKIP-SPACES"
                 WHEN OTHER
                     MOVE "]" TO LS-CH
                     PERFORM RAISE-EXPECTED
             END-EVALUATE
         END-IF
     END-PERFORM.

*> An element of an array is an integer whose suffix the prefix allows: B bytes (suffix b), I ints (none or i), L longs
*> (none or l); with a sign and the digits it is not a float, boolean or string.
 CHECK-ARRAY-ELEMENT.
     MOVE BR-IN-TEXT(BR-IN-CURSOR:1) TO LS-CH
     MOVE 1 TO LS-OK
     IF LS-SUB NOT = 5
         MOVE 0 TO LS-OK
     END-IF
     IF LS-OK = 1
         EVALUATE TRUE
             WHEN LS-PREFIX = "B" AND (LS-CH = "s" OR LS-CH = "S" OR LS-CH = "i" OR LS-CH = "I"
                     OR LS-CH = "l" OR LS-CH = "L")
                 MOVE 0 TO LS-OK
             WHEN LS-PREFIX = "I" AND (LS-CH = "b" OR LS-CH = "B" OR LS-CH = "s" OR LS-CH = "S"
                     OR LS-CH = "l" OR LS-CH = "L")
                 MOVE 0 TO LS-OK
             WHEN LS-PREFIX = "L" AND (LS-CH = "b" OR LS-CH = "B" OR LS-CH = "s" OR LS-CH = "S"
                     OR LS-CH = "i" OR LS-CH = "I")
                 MOVE 0 TO LS-OK
         END-EVALUATE
     END-IF
     IF LS-OK = 0
         MOVE "snbt.parser.invalid_array_element_type" TO LS-KEY
         MOVE LS-START TO LS-RC
         PERFORM RAISE-PLAIN
     END-IF.

*> ---- numbers, booleans, operations and unquoted strings -----------------------------------------------------
*> A token of unquoted characters from the cursor: [+-]digits... is a number; true and false are booleans; a name
*> followed by ( is an operation; any other token not starting with a digit, + or - is an unquoted string.
 DO-TOKEN.
     MOVE BR-IN-CURSOR TO LS-START
     MOVE LS-START TO LS-C
     PERFORM UNTIL LS-C >= BR-IN-LENGTH
         MOVE BR-IN-TEXT(LS-C + 1:1) TO LS-CH
         PERFORM UNQUOTED-CHAR
         IF LS-OK = 1
             ADD 1 TO LS-C
         ELSE
             EXIT PERFORM
         END-IF
     END-PERFORM
     COMPUTE LS-STR-LENGTH = LS-C - LS-START
     MOVE BR-IN-TEXT(LS-START + 1:1) TO LS-CH
     EVALUATE TRUE
         WHEN LS-CH = "-" OR LS-CH = "+" OR (LS-CH >= "0" AND LS-CH <= "9")
             PERFORM DO-NUMBER
         WHEN LS-C < BR-IN-LENGTH AND BR-IN-TEXT(LS-C + 1:1) = "("
             PERFORM DO-OPERATION
         WHEN LS-STR-LENGTH = 4 AND BR-IN-TEXT(LS-START + 1:4) = "true"
         WHEN LS-STR-LENGTH = 5 AND BR-IN-TEXT(LS-START + 1:5) = "false"
             MOVE 7 TO L-KIND
             MOVE LS-C TO BR-IN-CURSOR
         WHEN OTHER
             MOVE 4 TO L-KIND
             MOVE LS-C TO BR-IN-CURSOR
     END-EVALUATE.

*> The number token [LS-START, LS-C): sign, then decimal digits (no leading zero before more digits, _ between
*> digits only), 0x hexadecimal or 0b binary digits, an optional fraction and exponent (floating point), then the
*> type suffix: s or u then b s i l for an integer, f or d for a float (an integer with f or d is a float).
 DO-NUMBER.
     MOVE 5 TO L-KIND
     MOVE 1 TO LS-OK
     MOVE "snbt.parser.invalid_unquoted_start" TO LS-REASON
     MOVE 0 TO LS-IS-FLOAT
     COMPUTE LS-I = LS-START + 1
     IF BR-IN-TEXT(LS-I:1) = "-" OR BR-IN-TEXT(LS-I:1) = "+"
         ADD 1 TO LS-I
     END-IF
     IF LS-I > LS-C
         MOVE 0 TO LS-OK
     ELSE
         MOVE 0 TO LS-DIGITS
         MOVE 10 TO LS-BASE
         IF LS-I < LS-C AND BR-IN-TEXT(LS-I:1) = "0"
             EVALUATE BR-IN-TEXT(LS-I + 1:1)
                 WHEN "x"
                 WHEN "X"
                     MOVE 16 TO LS-BASE
                 WHEN "b"
                 WHEN "B"
                     MOVE 2 TO LS-BASE
             END-EVALUATE
             IF LS-BASE NOT = 10
                 ADD 2 TO LS-I
             END-IF
         END-IF
         PERFORM NUMBER-BODY
     END-IF
     IF LS-OK = 0
         MOVE LS-C TO BR-IN-CURSOR
         MOVE LS-REASON TO LS-KEY
         MOVE LS-START TO LS-RC
         PERFORM RAISE-PLAIN
     ELSE
         IF LS-IS-FLOAT = 1
             MOVE 6 TO L-KIND
         END-IF
         MOVE LS-C TO BR-IN-CURSOR
     END-IF.

*> The digits of the base from LS-I, then (decimal) a fraction, an exponent, and the suffix up to LS-C.
 NUMBER-BODY.
     MOVE 0 TO LS-LEAD-ZERO
     PERFORM UNTIL LS-I > LS-C OR LS-OK = 0
         MOVE BR-IN-TEXT(LS-I:1) TO LS-CH
         EVALUATE TRUE
             WHEN LS-CH = "_"
                 IF LS-DIGITS = 0 OR LS-I = LS-C
                     MOVE 0 TO LS-OK
                     MOVE "snbt.parser.undescore_not_allowed" TO LS-REASON
                 END-IF
                 ADD 1 TO LS-I
             WHEN (LS-CH >= "0" AND LS-CH <= "9")
                     OR (LS-BASE = 16 AND ((LS-CH >= "a" AND LS-CH <= "f") OR (LS-CH >= "A" AND LS-CH <= "F")))
                 IF LS-BASE = 2 AND LS-CH > "1"
                     MOVE 0 TO LS-OK
                 END-IF
                 IF LS-BASE = 10 AND LS-DIGITS = 1 AND LS-LEAD-ZERO = 1
                     MOVE 0 TO LS-OK
                     MOVE "snbt.parser.leading_zero_not_allowed" TO LS-REASON
                 END-IF
                 IF LS-DIGITS = 0 AND LS-CH = "0"
                     MOVE 1 TO LS-LEAD-ZERO
                 END-IF
                 ADD 1 TO LS-DIGITS
                 ADD 1 TO LS-I
             WHEN LS-BASE = 10 AND (LS-CH = "." OR LS-CH = "e" OR LS-CH = "E")
                 MOVE 1 TO LS-IS-FLOAT
                 MOVE 0 TO LS-LEAD-ZERO
                 IF LS-CH = "."
                     ADD 1 TO LS-I
                 END-IF
                 PERFORM FRACTION
             WHEN OTHER
                 PERFORM SUFFIX
         END-EVALUATE
     END-PERFORM
     IF LS-DIGITS = 0
         MOVE 0 TO LS-OK
     END-IF.

 FRACTION.
     PERFORM UNTIL LS-I > LS-C OR NOT (BR-IN-TEXT(LS-I:1) >= "0" AND BR-IN-TEXT(LS-I:1) <= "9")
         ADD 1 TO LS-I
     END-PERFORM
     IF LS-I <= LS-C AND (BR-IN-TEXT(LS-I:1) = "e" OR BR-IN-TEXT(LS-I:1) = "E")
         ADD 1 TO LS-I
         IF LS-I <= LS-C AND (BR-IN-TEXT(LS-I:1) = "-" OR BR-IN-TEXT(LS-I:1) = "+")
             ADD 1 TO LS-I
         END-IF
         IF LS-I > LS-C OR NOT (BR-IN-TEXT(LS-I:1) >= "0" AND BR-IN-TEXT(LS-I:1) <= "9")
             MOVE 0 TO LS-OK
         END-IF
         PERFORM UNTIL LS-I > LS-C OR NOT (BR-IN-TEXT(LS-I:1) >= "0" AND BR-IN-TEXT(LS-I:1) <= "9")
             ADD 1 TO LS-I
         END-PERFORM
     END-IF
     PERFORM SUFFIX.

*> The rest of the token from LS-I must be a valid suffix (or nothing); the scan then ends.
 SUFFIX.
     COMPUTE LS-STR-LENGTH = LS-C - LS-I + 1
     EVALUATE TRUE
         WHEN LS-STR-LENGTH = 0
             CONTINUE
         WHEN LS-STR-LENGTH = 1 AND LS-BASE = 10 AND (BR-IN-TEXT(LS-I:1) = "f" OR BR-IN-TEXT(LS-I:1) = "F"
                 OR BR-IN-TEXT(LS-I:1) = "d" OR BR-IN-TEXT(LS-I:1) = "D")
             MOVE 1 TO LS-IS-FLOAT
         WHEN LS-IS-FLOAT = 1
             MOVE 0 TO LS-OK
         WHEN LS-STR-LENGTH = 1
             MOVE BR-IN-TEXT(LS-I:1) TO LS-CH
             PERFORM INT-TYPE
         WHEN LS-STR-LENGTH = 2 AND (BR-IN-TEXT(LS-I:1) = "s" OR BR-IN-TEXT(LS-I:1) = "S"
                 OR BR-IN-TEXT(LS-I:1) = "u" OR BR-IN-TEXT(LS-I:1) = "U")
             MOVE BR-IN-TEXT(LS-I + 1:1) TO LS-CH
             PERFORM INT-TYPE
         WHEN OTHER
             MOVE 0 TO LS-OK
     END-EVALUATE
     COMPUTE LS-I = LS-C + 1.

*> LS-CH is a type letter b s i l: an invalid one clears LS-OK, a valid one keeps it.
 INT-TYPE.
     IF NOT (LS-CH = "b" OR LS-CH = "B" OR LS-CH = "s" OR LS-CH = "S" OR LS-CH = "i" OR LS-CH = "I"
             OR LS-CH = "l" OR LS-CH = "L")
         MOVE 0 TO LS-OK
     END-IF.

*> bool(value) and uuid("text") (15 §9.4); the value or string is read here, then the closing parenthesis.
 DO-OPERATION.
     MOVE LS-C TO BR-IN-CURSOR
     EVALUATE TRUE
         WHEN LS-STR-LENGTH = 4 AND BR-IN-TEXT(LS-START + 1:4) = "bool"
             MOVE 7 TO L-KIND
         WHEN LS-STR-LENGTH = 4 AND BR-IN-TEXT(LS-START + 1:4) = "uuid"
             MOVE 3 TO L-KIND
         WHEN OTHER
             MOVE "snbt.parser.no_such_operation" TO LS-KEY
             MOVE LS-STR-LENGTH TO LS-L1
             MOVE SPACES TO LS-A1
             MOVE BR-IN-TEXT(LS-START + 1:LS-L1) TO LS-A1(1:LS-L1)
             MOVE LS-START TO LS-RC
             MOVE 1 TO LS-N-ARGS
             MOVE 0 TO LS-L2
             CALL "BR-RAISE" USING LS-KEY LS-N-ARGS LS-A1 LS-L1 LS-A2 LS-L2 LS-RC
     END-EVALUATE
     IF BR-E-KEY = SPACES
         ADD 1 TO BR-IN-CURSOR
         CALL "BR-SNBT-SKIP-SPACES"
         CALL "BR-SNBT-VALUE" USING LS-SUB
         CALL "BR-SNBT-SKIP-SPACES"
         IF BR-E-KEY = SPACES
             IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ")"
                 ADD 1 TO BR-IN-CURSOR
             ELSE
                 MOVE ")" TO LS-CH
                 PERFORM RAISE-EXPECTED
             END-IF
         END-IF
     END-IF.

 MAIN-LINE.
     MOVE 0 TO L-KIND
     IF BR-IN-CURSOR >= BR-IN-LENGTH
         MOVE "argument.nbt.expected.value" TO LS-KEY
         MOVE BR-IN-CURSOR TO LS-RC
         PERFORM RAISE-PLAIN
     ELSE
         MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO LS-CH
         EVALUATE TRUE
             WHEN LS-CH = "{"
                 PERFORM DO-COMPOUND
             WHEN LS-CH = "["
                 PERFORM DO-LIST
             WHEN LS-CH = '"' OR LS-CH = "'"
                 MOVE 4 TO L-KIND
                 CALL "BR-SNBT-STRING" USING BR-IN-CURSOR LS-STR LS-STR-LENGTH
             WHEN OTHER
                 PERFORM UNQUOTED-CHAR
                 IF LS-OK = 1
                     PERFORM DO-TOKEN
                 ELSE
                     MOVE "argument.nbt.expected.value" TO LS-KEY
                     MOVE BR-IN-CURSOR TO LS-RC
                     PERFORM RAISE-PLAIN
                 END-IF
         END-EVALUATE
     END-IF.
 END PROGRAM BR-SNBT-VALUE.
