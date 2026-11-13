*> SNBT into the NBT value tree and back (docs/protocol/15-commands-framework.md §9.4; core/copy/NBXTREE.cpy). The builder trusts text the SNBT recogniser
*> (core/src/cmd-snbt.cob) accepted: it does no error reporting. The print form is NOT in the docs (gap): compound `{key:value,...}` with a bare key when it
*> is non-empty and made of A-Z a-z 0-9 _ . + - (else quoted), strings in double quotes with \ and " escaped (no other escapes), byte `1b`, short `1s`, int `1`,
*> long `1L`, float `1.5f`, double `1.5d` (shortest digits, 15a §5 rule), arrays `[B;1B]` `[I;1]` `[L;1L]`, lists `[a,b]`, no spaces.
*> Entry points:
*>   NBX-PARSE USING text (PIC X(1024)), start, end (0-based offsets), node out
*>   NBX-PRINT USING node, out (PIC X(4096)), position (BINARY-LONG, 1-based next byte, in and out)
*>   NBX-WRAP USING type (1 byte, 2 short, 3 int, 4 long), value (BINARY-DOUBLE in and out): wrapped to the type's range
*>   NBX-HEXDIGIT USING char, digit out (99 when not a hexadecimal digit)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-WRAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                BINARY-DOUBLE.
 01 WS-FULL                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TYPE L-VALUE.
     EVALUATE L-TYPE
         WHEN 1
             MOVE 128 TO WS-HALF
             MOVE 256 TO WS-FULL
         WHEN 2
             MOVE 32768 TO WS-HALF
             MOVE 65536 TO WS-FULL
         WHEN 3
             MOVE 2147483648 TO WS-HALF
             MOVE 4294967296 TO WS-FULL
         WHEN OTHER
             MOVE 0 TO WS-FULL
     END-EVALUATE
     IF WS-FULL > 0
         COMPUTE L-VALUE = FUNCTION MOD(L-VALUE + WS-HALF, WS-FULL) - WS-HALF
     END-IF
     GOBACK.
 END PROGRAM NBX-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-HEXDIGIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CH                   PIC X.
 01 L-DIGIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CH L-DIGIT.
     EVALUATE TRUE
         WHEN L-CH >= "0" AND L-CH <= "9"
             COMPUTE L-DIGIT = FUNCTION ORD(L-CH) - 49
         WHEN L-CH >= "a" AND L-CH <= "f"
             COMPUTE L-DIGIT = FUNCTION ORD(L-CH) - 88
         WHEN L-CH >= "A" AND L-CH <= "F"
             COMPUTE L-DIGIT = FUNCTION ORD(L-CH) - 56
         WHEN OTHER
             MOVE 99 TO L-DIGIT
     END-EVALUATE
     GOBACK.
 END PROGRAM NBX-HEXDIGIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-UUID.
*> USING text (PIC X(256)), length, node out: an int array of the four 32-bit words of the hexadecimal digits of the text (dashes skipped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-T-INT-ARRAY         BINARY-LONG VALUE 11.
 01 WS-T-INT               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WORD                BINARY-DOUBLE.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-NODE.
     CALL "NBX-NEW" USING WS-T-INT-ARRAY L-NODE
     MOVE 0 TO WS-COUNT WS-WORD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         MOVE L-TEXT(WS-I:1) TO WS-CH
         CALL "NBX-HEXDIGIT" USING WS-CH WS-DIGIT
         IF WS-DIGIT < 16
             COMPUTE WS-WORD = WS-WORD * 16 + WS-DIGIT
             ADD 1 TO WS-COUNT
             IF WS-COUNT = 8
                 CALL "NBX-WRAP" USING WS-T-INT WS-WORD
                 CALL "NBX-NEW" USING WS-T-INT WS-CHILD
                 MOVE WS-WORD TO NX-INT(WS-CHILD)
                 CALL "NBX-ADD" USING L-NODE WS-CHILD
                 MOVE 0 TO WS-COUNT WS-WORD
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-NUMBER.
*> USING token (PIC X(1024)), length, node out: the number token the recogniser accepted (15 §9.4: sign, decimal, 0x or 0b numeral, `_` separators,
*> fraction, exponent, suffix) as a node; no suffix gives an int, or a double when it has a fraction or exponent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-I                   BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-VAL                 BINARY-DOUBLE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-FLOATY              BINARY-LONG.
 01 WS-LAST                PIC X.
 01 WS-BUF                 PIC X(64).
 01 WS-BLEN                BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-NODE.
     MOVE 1 TO WS-I
     MOVE 0 TO WS-NEG
     MOVE 10 TO WS-BASE
     IF L-TEXT(1:1) = "-"
         MOVE 1 TO WS-NEG
     END-IF
     IF L-TEXT(1:1) = "-" OR L-TEXT(1:1) = "+"
         MOVE 2 TO WS-I
     END-IF
     IF WS-I + 1 < L-LENGTH AND L-TEXT(WS-I:1) = "0"
         MOVE FUNCTION LOWER-CASE(L-TEXT(WS-I + 1:1)) TO WS-CH
         IF WS-CH = "x"
             MOVE 16 TO WS-BASE
         END-IF
         IF WS-CH = "b"
             MOVE 2 TO WS-BASE
         END-IF
         IF WS-BASE NOT = 10
             ADD 2 TO WS-I
         END-IF
     END-IF
     MOVE FUNCTION LOWER-CASE(L-TEXT(L-LENGTH:1)) TO WS-LAST
     MOVE 0 TO WS-FLOATY
     IF WS-BASE = 10
         IF WS-LAST = "f" OR WS-LAST = "d"
             MOVE 1 TO WS-FLOATY
         END-IF
         PERFORM VARYING WS-STOP FROM 1 BY 1 UNTIL WS-STOP > L-LENGTH
             IF L-TEXT(WS-STOP:1) = "." OR L-TEXT(WS-STOP:1) = "e" OR L-TEXT(WS-STOP:1) = "E"
                 MOVE 1 TO WS-FLOATY
             END-IF
         END-PERFORM
     END-IF
     IF WS-FLOATY = 1
         MOVE SPACES TO WS-BUF
         MOVE 0 TO WS-BLEN
         PERFORM VARYING WS-STOP FROM 1 BY 1 UNTIL WS-STOP > L-LENGTH
             IF L-TEXT(WS-STOP:1) NOT = "_" AND WS-BLEN < 64
                 ADD 1 TO WS-BLEN
                 MOVE L-TEXT(WS-STOP:1) TO WS-BUF(WS-BLEN:1)
             END-IF
         END-PERFORM
         MOVE 6 TO WS-TYPE
         IF WS-LAST = "f" OR WS-LAST = "d"
             SUBTRACT 1 FROM WS-BLEN
             IF WS-LAST = "f"
                 MOVE 5 TO WS-TYPE
             END-IF
         END-IF
         CALL "NBX-NEW" USING WS-TYPE L-NODE
         COMPUTE NX-DBL(L-NODE) = FUNCTION NUMVAL-F(WS-BUF(1:WS-BLEN))
     ELSE
         MOVE 0 TO WS-VAL
         MOVE 0 TO WS-STOP
         PERFORM UNTIL WS-I > L-LENGTH OR WS-STOP = 1
             MOVE L-TEXT(WS-I:1) TO WS-CH
             IF WS-CH = "_"
                 ADD 1 TO WS-I
             ELSE
                 CALL "NBX-HEXDIGIT" USING WS-CH WS-DIGIT
                 IF WS-DIGIT < WS-BASE
                     COMPUTE WS-VAL = WS-VAL * WS-BASE + WS-DIGIT
                     ADD 1 TO WS-I
                 ELSE
                     MOVE 1 TO WS-STOP
                 END-IF
             END-IF
         END-PERFORM
         MOVE 3 TO WS-TYPE
         IF WS-I <= L-LENGTH
             EVALUATE WS-LAST
                 WHEN "b"
                     MOVE 1 TO WS-TYPE
                 WHEN "s"
                     MOVE 2 TO WS-TYPE
                 WHEN "l"
                     MOVE 4 TO WS-TYPE
             END-EVALUATE
         END-IF
         IF WS-NEG = 1
             COMPUTE WS-VAL = 0 - WS-VAL
         END-IF
         CALL "NBX-WRAP" USING WS-TYPE WS-VAL
         CALL "NBX-NEW" USING WS-TYPE L-NODE
         MOVE WS-VAL TO NX-INT(L-NODE)
     END-IF
     GOBACK.
 END PROGRAM NBX-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PARSE-VALUE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY NBXTREE.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-T-BYTE              BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-CH                  PIC X.
 01 LS-STR                 PIC X(1024).
 01 LS-LEN                 BINARY-LONG.
 01 LS-KEY                 PIC X(64).
 01 LS-KLEN                BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-ARRAY               BINARY-LONG.
 01 LS-ELEMENT             BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE.
     GO TO MAIN-LINE.

 MAKE-STRING.
     CALL "NBX-NEW" USING WS-T-STRING L-NODE
     COMPUTE NX-SLEN(L-NODE) = FUNCTION MIN(LS-LEN, 256)
     MOVE LS-STR TO NX-STR(L-NODE).

 DO-COMPOUND.
     CALL "NBX-NEW" USING WS-T-COMPOUND L-NODE
     ADD 1 TO BR-IN-CURSOR
     MOVE 0 TO LS-DONE
     PERFORM UNTIL LS-DONE = 1
         CALL "BR-SNBT-SKIP-SPACES"
         IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO LS-DONE
         ELSE
             CALL "BR-SNBT-STRING" USING BR-IN-CURSOR LS-STR LS-LEN
             MOVE LS-STR TO LS-KEY
             COMPUTE LS-KLEN = FUNCTION MIN(LS-LEN, 64)
             CALL "BR-SNBT-SKIP-SPACES"
             ADD 1 TO BR-IN-CURSOR
             CALL "NBX-PARSE-VALUE" USING LS-CHILD
             CALL "NBX-SET" USING L-NODE LS-KEY LS-KLEN LS-CHILD
             CALL "BR-SNBT-SKIP-SPACES"
             IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                 ADD 1 TO BR-IN-CURSOR
             END-IF
         END-IF
     END-PERFORM.

*> A list, or an array when [B; [I; or [L; starts it (its elements take the array's element type).
 DO-LIST.
     ADD 1 TO BR-IN-CURSOR
     MOVE 9 TO LS-TYPE
     MOVE 0 TO LS-ELEMENT
     IF BR-IN-TEXT(BR-IN-CURSOR + 2:1) = ";"
         EVALUATE BR-IN-TEXT(BR-IN-CURSOR + 1:1)
             WHEN "B"
                 MOVE 7 TO LS-TYPE
                 MOVE 1 TO LS-ELEMENT
             WHEN "I"
                 MOVE 11 TO LS-TYPE
                 MOVE 3 TO LS-ELEMENT
             WHEN "L"
                 MOVE 12 TO LS-TYPE
                 MOVE 4 TO LS-ELEMENT
         END-EVALUATE
         IF LS-TYPE NOT = 9
             ADD 2 TO BR-IN-CURSOR
         END-IF
     END-IF
     CALL "NBX-NEW" USING LS-TYPE L-NODE
     MOVE 0 TO LS-DONE
     PERFORM UNTIL LS-DONE = 1
         CALL "BR-SNBT-SKIP-SPACES"
         IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO LS-DONE
         ELSE
             CALL "NBX-PARSE-VALUE" USING LS-CHILD
             IF LS-ELEMENT > 0
                 MOVE LS-ELEMENT TO NX-TYPE(LS-CHILD)
                 CALL "NBX-WRAP" USING LS-ELEMENT NX-INT(LS-CHILD)
             END-IF
             CALL "NBX-ADD" USING L-NODE LS-CHILD
             CALL "BR-SNBT-SKIP-SPACES"
             IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                 ADD 1 TO BR-IN-CURSOR
             END-IF
         END-IF
     END-PERFORM.

*> An unquoted token: a number, bool( or uuid( operation, true, false, or an unquoted string.
 DO-TOKEN.
     CALL "BR-SNBT-STRING" USING BR-IN-CURSOR LS-STR LS-LEN
     MOVE LS-STR(1:1) TO LS-CH
     EVALUATE TRUE
         WHEN LS-CH = "-" OR LS-CH = "+" OR (LS-CH >= "0" AND LS-CH <= "9")
             CALL "NBX-NUMBER" USING LS-STR LS-LEN L-NODE
         WHEN BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "("
             ADD 1 TO BR-IN-CURSOR
             CALL "NBX-PARSE-VALUE" USING LS-SUB
             CALL "BR-SNBT-SKIP-SPACES"
             ADD 1 TO BR-IN-CURSOR
             IF LS-STR(1:4) = "bool"
                 MOVE 1 TO NX-TYPE(LS-SUB)
                 IF NX-INT(LS-SUB) NOT = 0
                     MOVE 1 TO NX-INT(LS-SUB)
                 END-IF
                 MOVE LS-SUB TO L-NODE
             ELSE
                 CALL "NBX-UUID" USING NX-STR(LS-SUB) NX-SLEN(LS-SUB) L-NODE
                 CALL "NBX-FREE" USING LS-SUB
             END-IF
         WHEN (LS-LEN = 4 AND LS-STR(1:4) = "true") OR (LS-LEN = 5 AND LS-STR(1:5) = "false")
             CALL "NBX-NEW" USING WS-T-BYTE L-NODE
             IF LS-LEN = 4
                 MOVE 1 TO NX-INT(L-NODE)
             END-IF
         WHEN OTHER
             PERFORM MAKE-STRING
     END-EVALUATE.

 MAIN-LINE.
     CALL "BR-SNBT-SKIP-SPACES"
     MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO LS-CH
     EVALUATE TRUE
         WHEN LS-CH = "{"
             PERFORM DO-COMPOUND
         WHEN LS-CH = "["
             PERFORM DO-LIST
         WHEN LS-CH = '"' OR LS-CH = "'"
             CALL "BR-SNBT-STRING" USING BR-IN-CURSOR LS-STR LS-LEN
             PERFORM MAKE-STRING
         WHEN OTHER
             PERFORM DO-TOKEN
     END-EVALUATE
     GOBACK.
 END PROGRAM NBX-PARSE-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PARSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-START L-END L-NODE.
     MOVE L-TEXT TO BR-IN-TEXT
     MOVE L-END TO BR-IN-LENGTH
     MOVE L-START TO BR-IN-CURSOR
     CALL "NBX-PARSE-VALUE" USING L-NODE
     GOBACK.
 END PROGRAM NBX-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PRINT RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-INT-ZERO            BINARY-DOUBLE VALUE 0.
 01 WS-NO-INF              BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-FIRST               BINARY-LONG.
 01 LS-EDIT                PIC -(19)9.
 01 LS-NUM                 PIC X(32).
 01 LS-NLEN                BINARY-LONG.
 01 LS-TEXT                PIC X(256).
 01 LS-TLEN                BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-CH                  PIC X.
 01 LS-BARE                BINARY-LONG.
 01 LS-SUFFIX              PIC X.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-OUT                  PIC X(4096).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-OUT L-POS.
     GO TO MAIN-LINE.

*> LS-TEXT(1:LS-TLEN) in double quotes, \ and " escaped.
 PUT-QUOTED.
     STRING '"' DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-TLEN
         MOVE LS-TEXT(LS-I:1) TO LS-CH
         IF LS-CH = '"' OR LS-CH = "\"
             STRING "\" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         END-IF
         STRING LS-CH DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
     END-PERFORM
     STRING '"' DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS.

*> The key of the entry LS-CHILD: bare when it is made of A-Z a-z 0-9 _ . + -, else quoted.
 PUT-KEY.
     MOVE NX-KLEN(LS-CHILD) TO LS-TLEN
     MOVE NX-KEY(LS-CHILD) TO LS-TEXT
     MOVE 1 TO LS-BARE
     IF LS-TLEN = 0
         MOVE 0 TO LS-BARE
     END-IF
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-TLEN
         MOVE LS-TEXT(LS-I:1) TO LS-CH
         IF NOT ((LS-CH >= "0" AND LS-CH <= "9") OR (LS-CH >= "a" AND LS-CH <= "z")
                 OR (LS-CH >= "A" AND LS-CH <= "Z") OR LS-CH = "_" OR LS-CH = "." OR LS-CH = "+" OR LS-CH = "-")
             MOVE 0 TO LS-BARE
         END-IF
     END-PERFORM
     IF LS-BARE = 1
         STRING LS-TEXT(1:LS-TLEN) DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
     ELSE
         PERFORM PUT-QUOTED
     END-IF.

*> The integer value of node LS-CHILD with the suffix LS-SUFFIX (a space: none).
 PUT-INT.
     MOVE NX-INT(LS-CHILD) TO LS-EDIT
     IF LS-SUFFIX = SPACE
         STRING FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
     ELSE
         STRING FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE LS-SUFFIX DELIMITED BY SIZE
             INTO L-OUT WITH POINTER L-POS
     END-IF.

*> The elements of an array or list node, comma separated; arrays print each element with LS-SUFFIX.
 PUT-ELEMENTS.
     MOVE 1 TO LS-FIRST
     MOVE NX-FIRST(L-NODE) TO LS-CHILD
     PERFORM UNTIL LS-CHILD = 0
         IF LS-FIRST = 0
             STRING "," DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         END-IF
         MOVE 0 TO LS-FIRST
         IF NX-TYPE(L-NODE) = 9
             CALL "NBX-PRINT" USING LS-CHILD L-OUT L-POS
         ELSE
             PERFORM PUT-INT
         END-IF
         MOVE NX-NEXT(LS-CHILD) TO LS-CHILD
     END-PERFORM.

 MAIN-LINE.
     EVALUATE NX-TYPE(L-NODE)
         WHEN 1
             MOVE "b" TO LS-SUFFIX
             MOVE L-NODE TO LS-CHILD
             PERFORM PUT-INT
         WHEN 2
             MOVE "s" TO LS-SUFFIX
             MOVE L-NODE TO LS-CHILD
             PERFORM PUT-INT
         WHEN 3
             MOVE SPACE TO LS-SUFFIX
             MOVE L-NODE TO LS-CHILD
             PERFORM PUT-INT
         WHEN 4
             MOVE "L" TO LS-SUFFIX
             MOVE L-NODE TO LS-CHILD
             PERFORM PUT-INT
         WHEN 5
             CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO NX-DBL(L-NODE) WS-NO-INF LS-NUM LS-NLEN
             STRING LS-NUM(1:LS-NLEN) DELIMITED BY SIZE "f" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN 6
             CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE WS-INT-ZERO NX-DBL(L-NODE) WS-NO-INF LS-NUM LS-NLEN
             STRING LS-NUM(1:LS-NLEN) DELIMITED BY SIZE "d" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN 7
             STRING "[B;" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
             MOVE "B" TO LS-SUFFIX
             PERFORM PUT-ELEMENTS
             STRING "]" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN 8
             MOVE NX-SLEN(L-NODE) TO LS-TLEN
             MOVE NX-STR(L-NODE) TO LS-TEXT
             PERFORM PUT-QUOTED
         WHEN 9
             STRING "[" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
             PERFORM PUT-ELEMENTS
             STRING "]" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN 10
             STRING "{" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
             MOVE 1 TO LS-FIRST
             MOVE NX-FIRST(L-NODE) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0
                 IF LS-FIRST = 0
                     STRING "," DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
                 END-IF
                 MOVE 0 TO LS-FIRST
                 PERFORM PUT-KEY
                 STRING ":" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
                 CALL "NBX-PRINT" USING LS-CHILD L-OUT L-POS
                 MOVE NX-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
             STRING "}" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN 11
             STRING "[I;" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
             MOVE SPACE TO LS-SUFFIX
             PERFORM PUT-ELEMENTS
             STRING "]" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
         WHEN OTHER
             STRING "[L;" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
             MOVE "L" TO LS-SUFFIX
             PERFORM PUT-ELEMENTS
             STRING "]" DELIMITED BY SIZE INTO L-OUT WITH POINTER L-POS
     END-EVALUATE
     GOBACK.
 END PROGRAM NBX-PRINT.
