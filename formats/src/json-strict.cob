*> Strict JSON (docs/protocol/23-registry-loading.md §3.2: Gson STRICT, then the end of the document):
*> what the registry and data pack loaders read. JSON-STRICT scans the text once for the grammar of
*> RFC 8259 and gives the reason and byte offset of the first problem; a text that passes is handed to
*> the lenient JSON-PARSE for the node table (so a strict document has exactly the nodes of the lenient
*> reader, JSONDOC.cpy) and is then checked for repeated member names, which the grammar allows.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-STRICT.
*> USING text area, length (BINARY-LONG), JSON-DOC out, error offset out (BINARY-LONG, 0-based byte
*> offset), reason out (BINARY-LONG: FM-JS-OK or one of the FM-JS-* codes of FORMATS.cpy). The text
*> must stay alive while the document is used. A rejected text leaves JD-ERROR 1 and JD-COUNT 0.
*> Offsets: a comment (its "/"), a comma before a closing bracket (the comma), a repeated member name
*> (the opening quote of the later one), data after the document (its first byte), a number (its
*> first byte), a bad escape (its backslash), a control character (the character), an unquoted name
*> (its first byte), any other syntax problem (the byte, the end of the text when it ends too soon, the
*> opening quote of an unterminated string), nesting over 64 levels (the bracket) and more than
*> JD-MAX-NODES values (the value that does not fit).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
*> Modes: 1 a value is expected, 2 a value or "]" (just after "["), 3 a key or "}" (just after "{"),
*> 4 a key (after ","), 5 the colon, 6 "," or the container's close, 7 the end of the text.
 01 WS-MODE                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-STACK               BINARY-LONG OCCURS 65 TIMES.
 01 WS-TOP                 BINARY-LONG.
 01 WS-NODES               BINARY-LONG.
 01 WS-COMMA               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-START-NODE          BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 01 WS-KL                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ESCAPED             BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 B-TEXT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH JSON-DOC L-OFFSET L-REASON.
     SET ADDRESS OF B-TEXT TO ADDRESS OF L-TEXT
     MOVE FM-JS-OK TO WS-REASON
     MOVE 0 TO WS-OFFSET WS-DEPTH WS-NODES WS-COMMA
     MOVE 1 TO WS-MODE WS-POS
     PERFORM UNTIL WS-REASON NOT = FM-JS-OK OR (WS-MODE = 7 AND WS-POS > L-LENGTH)
*>       Whitespace between tokens.
         PERFORM UNTIL WS-POS > L-LENGTH
                 OR NOT (B-TEXT(WS-POS:1) = SPACE OR X"09" OR X"0A" OR X"0D")
             ADD 1 TO WS-POS
         END-PERFORM
         MOVE SPACE TO WS-C
         IF WS-POS <= L-LENGTH
             MOVE B-TEXT(WS-POS:1) TO WS-C
         END-IF
         MOVE 0 TO WS-TOP
         IF WS-DEPTH > 0
             MOVE WS-STACK(WS-DEPTH) TO WS-TOP
         END-IF
         COMPUTE WS-START = WS-POS - 1
         EVALUATE TRUE
             WHEN WS-POS > L-LENGTH AND WS-MODE = 7
*>               Only white space follows a finished document.
                 CONTINUE
             WHEN WS-POS > L-LENGTH
*>               The text ends inside the document.
                 MOVE FM-JS-SYNTAX TO WS-REASON
                 MOVE L-LENGTH TO WS-OFFSET
             WHEN WS-C = "/"
                 MOVE FM-JS-SYNTAX TO WS-REASON
                 IF WS-POS < L-LENGTH AND (B-TEXT(WS-POS + 1:1) = "/" OR "*")
                     MOVE FM-JS-COMMENT TO WS-REASON
                 END-IF
                 MOVE WS-START TO WS-OFFSET
             WHEN WS-MODE = 7
                 MOVE FM-JS-TRAILING-DATA TO WS-REASON
                 MOVE WS-START TO WS-OFFSET
             WHEN WS-MODE = 5
                 IF WS-C = ":"
                     ADD 1 TO WS-POS
                     MOVE 1 TO WS-MODE
                 ELSE
                     MOVE FM-JS-SYNTAX TO WS-REASON
                     MOVE WS-START TO WS-OFFSET
                 END-IF
             WHEN WS-MODE = 6
                 EVALUATE TRUE
                     WHEN WS-C = "," AND WS-TOP = JT-OBJECT
                         MOVE WS-START TO WS-COMMA
                         ADD 1 TO WS-POS
                         MOVE 4 TO WS-MODE
                     WHEN WS-C = ","
                         MOVE WS-START TO WS-COMMA
                         ADD 1 TO WS-POS
                         MOVE 1 TO WS-MODE
                     WHEN (WS-C = "}" AND WS-TOP = JT-OBJECT) OR (WS-C = "]" AND WS-TOP = JT-ARRAY)
                         SUBTRACT 1 FROM WS-DEPTH
                         ADD 1 TO WS-POS
                         MOVE 6 TO WS-MODE
                         IF WS-DEPTH = 0
                             MOVE 7 TO WS-MODE
                         END-IF
                     WHEN OTHER
                         MOVE FM-JS-SYNTAX TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                 END-EVALUATE
             WHEN WS-MODE = 3 OR WS-MODE = 4
*>               A member name, or the end of the object (only right after "{").
                 EVALUATE TRUE
                     WHEN WS-C = '"'
                         CALL "JSON-STRICT-STRING" USING B-TEXT L-LENGTH WS-POS WS-END WS-REASON WS-OFFSET
                         COMPUTE WS-POS = WS-END + 1
                         MOVE 5 TO WS-MODE
                     WHEN WS-C = "}" AND WS-MODE = 3
                         SUBTRACT 1 FROM WS-DEPTH
                         ADD 1 TO WS-POS
                         MOVE 6 TO WS-MODE
                         IF WS-DEPTH = 0
                             MOVE 7 TO WS-MODE
                         END-IF
                     WHEN WS-C = "}"
                         MOVE FM-JS-TRAILING-COMMA TO WS-REASON
                         MOVE WS-COMMA TO WS-OFFSET
                     WHEN WS-C IS ALPHABETIC OR WS-C IS NUMERIC OR WS-C = "_" OR "$"
                         MOVE FM-JS-UNQUOTED-NAME TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                     WHEN OTHER
                         MOVE FM-JS-SYNTAX TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                 END-EVALUATE
             WHEN WS-C = "]" AND WS-MODE = 2
                 SUBTRACT 1 FROM WS-DEPTH
                 ADD 1 TO WS-POS
                 MOVE 6 TO WS-MODE
                 IF WS-DEPTH = 0
                     MOVE 7 TO WS-MODE
                 END-IF
             WHEN WS-C = "]" AND WS-MODE = 1 AND WS-TOP = JT-ARRAY
                 MOVE FM-JS-TRAILING-COMMA TO WS-REASON
                 MOVE WS-COMMA TO WS-OFFSET
             WHEN OTHER
*>               A value (mode 1 or 2). Every value is a node of the document.
                 ADD 1 TO WS-NODES
                 IF WS-NODES > JD-MAX-NODES
                     MOVE FM-JS-CAPACITY TO WS-REASON
                     MOVE WS-START TO WS-OFFSET
                 END-IF
                 MOVE 6 TO WS-MODE
                 EVALUATE TRUE
                     WHEN WS-REASON NOT = FM-JS-OK
                         CONTINUE
                     WHEN WS-C = "{" OR WS-C = "["
                         ADD 1 TO WS-POS
                         ADD 1 TO WS-DEPTH
                         IF WS-C = "{"
                             MOVE 3 TO WS-MODE
                             MOVE JT-OBJECT TO WS-STACK(WS-DEPTH)
                         ELSE
                             MOVE 2 TO WS-MODE
                             MOVE JT-ARRAY TO WS-STACK(WS-DEPTH)
                         END-IF
                         IF WS-DEPTH > 64
                             MOVE FM-JS-DEPTH TO WS-REASON
                             MOVE WS-START TO WS-OFFSET
                         END-IF
                     WHEN WS-C = '"'
                         CALL "JSON-STRICT-STRING" USING B-TEXT L-LENGTH WS-POS WS-END WS-REASON WS-OFFSET
                         COMPUTE WS-POS = WS-END + 1
                     WHEN WS-C = "t" AND WS-POS + 3 <= L-LENGTH AND B-TEXT(WS-POS:4) = "true"
                         ADD 4 TO WS-POS
                     WHEN WS-C = "f" AND WS-POS + 4 <= L-LENGTH AND B-TEXT(WS-POS:5) = "false"
                         ADD 5 TO WS-POS
                     WHEN WS-C = "n" AND WS-POS + 3 <= L-LENGTH AND B-TEXT(WS-POS:4) = "null"
                         ADD 4 TO WS-POS
                     WHEN WS-C = "N" AND WS-POS + 2 <= L-LENGTH AND B-TEXT(WS-POS:3) = "NaN"
                         MOVE FM-JS-NUMBER TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                     WHEN WS-C = "I" AND WS-POS + 7 <= L-LENGTH AND B-TEXT(WS-POS:8) = "Infinity"
                         MOVE FM-JS-NUMBER TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                     WHEN WS-C = "-" OR WS-C IS NUMERIC
                         CALL "JSON-STRICT-NUMBER" USING B-TEXT L-LENGTH WS-POS WS-REASON WS-OFFSET
                     WHEN OTHER
                         MOVE FM-JS-SYNTAX TO WS-REASON
                         MOVE WS-START TO WS-OFFSET
                 END-EVALUATE
                 IF WS-DEPTH = 0 AND WS-MODE = 6
                     MOVE 7 TO WS-MODE
                 END-IF
         END-EVALUATE
     END-PERFORM

*>   The grammar holds: the nodes come from the lenient reader, then member names must differ.
     IF WS-REASON = FM-JS-OK
         CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
         MOVE 0 TO WS-BEST
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > JD-COUNT
             IF JN-TYPE(WS-N) = JT-OBJECT AND JN-COUNT(WS-N) > 1
*>               Escapes in a name need the decoded text to compare; otherwise the raw text does.
                 MOVE 0 TO WS-ESCAPED
                 MOVE JN-FIRST(WS-N) TO WS-B
                 PERFORM UNTIL WS-B = 0
                     MOVE JN-KEY-POS(WS-B) TO WS-KP
                     MOVE JN-KEY-LENGTH(WS-B) TO WS-KL
                     MOVE 0 TO WS-COUNT
                     IF WS-KL > 0
                         INSPECT B-TEXT(WS-KP:WS-KL) TALLYING WS-COUNT FOR ALL "\"
                     END-IF
                     IF WS-COUNT > 0
                         MOVE 1 TO WS-ESCAPED
                     END-IF
                     MOVE JN-NEXT(WS-B) TO WS-B
                 END-PERFORM
*>               Each member against the ones before it; the first repeat of the object is the one
*>               nearest the start of the text.
                 MOVE JN-FIRST(WS-N) TO WS-B
                 MOVE 0 TO WS-SAME
                 PERFORM UNTIL WS-B = 0 OR WS-SAME = 1
                     MOVE JN-FIRST(WS-N) TO WS-A
                     PERFORM UNTIL WS-A = WS-B OR WS-SAME = 1
                         IF JN-KEY-LENGTH(WS-A) = JN-KEY-LENGTH(WS-B) OR WS-ESCAPED = 1
                             CALL "JSON-STRICT-SAME-KEY" USING JSON-DOC WS-A WS-B WS-ESCAPED WS-SAME
                         END-IF
                         MOVE JN-NEXT(WS-A) TO WS-A
                     END-PERFORM
                     IF WS-SAME = 0
                         MOVE JN-NEXT(WS-B) TO WS-B
                     END-IF
                 END-PERFORM
                 IF WS-SAME = 1
                     COMPUTE WS-LAST = JN-KEY-POS(WS-B) - 2
                     IF WS-BEST = 0 OR WS-LAST + 1 < WS-BEST
                         COMPUTE WS-BEST = WS-LAST + 1
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST > 0
             MOVE FM-JS-DUPLICATE-KEY TO WS-REASON
             COMPUTE WS-OFFSET = WS-BEST - 1
         END-IF
     END-IF
     IF WS-REASON NOT = FM-JS-OK
         SET JD-ADDR TO ADDRESS OF L-TEXT
         MOVE L-LENGTH TO JD-LENGTH
         MOVE 1 TO JD-ERROR
         MOVE 0 TO JD-COUNT
     END-IF
     MOVE WS-REASON TO L-REASON
     MOVE WS-OFFSET TO L-OFFSET
     GOBACK.
 END PROGRAM JSON-STRICT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-STRICT-STRING.
*> USING text, length, position of the opening quote (1-based), position of the closing quote out,
*> reason (set only on a problem), offset (0-based, set only on a problem): a string with a control
*> character or a bad escape is FM-JS-ESCAPE; one the text ends in is FM-JS-SYNTAX at its opening quote.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-K                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HEXDIGITS           PIC X(22) VALUE "0123456789abcdefABCDEF".
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1073741824).
 01 L-LENGTH               BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-START L-END L-REASON L-OFFSET.
     COMPUTE WS-K = L-START + 1
     MOVE 0 TO L-END
     PERFORM UNTIL L-END > 0 OR L-REASON NOT = FM-JS-OK
         EVALUATE TRUE
             WHEN WS-K > L-LENGTH
                 MOVE FM-JS-SYNTAX TO L-REASON
                 COMPUTE L-OFFSET = L-START - 1
                 MOVE L-LENGTH TO L-END
             WHEN L-TEXT(WS-K:1) < SPACE
                 MOVE FM-JS-ESCAPE TO L-REASON
                 COMPUTE L-OFFSET = WS-K - 1
                 MOVE L-LENGTH TO L-END
             WHEN L-TEXT(WS-K:1) = '"'
                 MOVE WS-K TO L-END
             WHEN L-TEXT(WS-K:1) NOT = "\"
                 ADD 1 TO WS-K
             WHEN WS-K = L-LENGTH
                 MOVE FM-JS-SYNTAX TO L-REASON
                 COMPUTE L-OFFSET = L-START - 1
                 MOVE L-LENGTH TO L-END
             WHEN L-TEXT(WS-K + 1:1) = '"' OR "\" OR "/" OR "b" OR "f" OR "n" OR "r" OR "t"
                 ADD 2 TO WS-K
             WHEN L-TEXT(WS-K + 1:1) = "u" AND WS-K + 5 <= L-LENGTH
                 PERFORM VARYING WS-H FROM 2 BY 1 UNTIL WS-H > 5
                     MOVE 0 TO WS-COUNT
                     INSPECT WS-HEXDIGITS TALLYING WS-COUNT FOR ALL L-TEXT(WS-K + WS-H:1)
                     IF WS-COUNT = 0
                         MOVE FM-JS-ESCAPE TO L-REASON
                         COMPUTE L-OFFSET = WS-K - 1
                         MOVE L-LENGTH TO L-END
                     END-IF
                 END-PERFORM
                 ADD 6 TO WS-K
             WHEN L-TEXT(WS-K + 1:1) = "u"
                 MOVE FM-JS-SYNTAX TO L-REASON
                 COMPUTE L-OFFSET = L-START - 1
                 MOVE L-LENGTH TO L-END
             WHEN OTHER
                 MOVE FM-JS-ESCAPE TO L-REASON
                 COMPUTE L-OFFSET = WS-K - 1
                 MOVE L-LENGTH TO L-END
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-STRICT-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-STRICT-NUMBER.
*> USING text, length, position (1-based, at the "-" or the first digit; moved past the number),
*> reason (set only on a problem), offset (0-based): -? (0 | [1-9][0-9]*) (. [0-9]+)? ([eE] [+-]? [0-9]+)?
*> A number that does not match is FM-JS-NUMBER at its first byte.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-START               BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1073741824).
 01 L-LENGTH               BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-POS L-REASON L-OFFSET.
     MOVE L-POS TO WS-START
     IF L-TEXT(L-POS:1) = "-"
         ADD 1 TO L-POS
     END-IF
*>   The integer part: one digit, or digits that do not start with 0.
     MOVE 0 TO WS-DIGITS
     PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
         IF WS-DIGITS = 1 AND L-TEXT(L-POS - 1:1) = "0"
             MOVE FM-JS-NUMBER TO L-REASON
         END-IF
         ADD 1 TO WS-DIGITS L-POS
     END-PERFORM
     IF WS-DIGITS = 0
         MOVE FM-JS-NUMBER TO L-REASON
     END-IF
     IF L-POS <= L-LENGTH AND L-TEXT(L-POS:1) = "."
         ADD 1 TO L-POS
         MOVE 0 TO WS-DIGITS
         PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
             ADD 1 TO WS-DIGITS L-POS
         END-PERFORM
         IF WS-DIGITS = 0
             MOVE FM-JS-NUMBER TO L-REASON
         END-IF
     END-IF
     IF L-POS <= L-LENGTH AND (L-TEXT(L-POS:1) = "e" OR "E")
         ADD 1 TO L-POS
         IF L-POS <= L-LENGTH AND (L-TEXT(L-POS:1) = "+" OR "-")
             ADD 1 TO L-POS
         END-IF
         MOVE 0 TO WS-DIGITS
         PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
             ADD 1 TO WS-DIGITS L-POS
         END-PERFORM
         IF WS-DIGITS = 0
             MOVE FM-JS-NUMBER TO L-REASON
         END-IF
     END-IF
     IF L-REASON = FM-JS-NUMBER
         COMPUTE L-OFFSET = WS-START - 1
     END-IF
     GOBACK.
 END PROGRAM JSON-STRICT-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-STRICT-SAME-KEY.
*> USING JSON-DOC, member node a, member node b, escaped flag, same out (set to 1 when the two members
*> have the same name; left alone otherwise). With the flag 0 the raw texts are compared (the lengths
*> are known to be equal); with 1 the names are decoded first (up to 1024 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A-KEY               PIC X(1024).
 01 WS-B-KEY               PIC X(1024).
 01 WS-CAP                 BINARY-LONG VALUE 1024.
 01 WS-A-LENGTH            BINARY-LONG.
 01 WS-B-LENGTH            BINARY-LONG.
 01 WS-A-DECODED           BINARY-LONG.
 01 WS-B-DECODED           BINARY-LONG.
 01 WS-A-POS               BINARY-LONG.
 01 WS-B-POS               BINARY-LONG.
 01 B-TEXT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-ESCAPED              BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-A L-B L-ESCAPED L-SAME.
     SET ADDRESS OF B-TEXT TO JD-ADDR
     MOVE JN-KEY-POS(L-A) TO WS-A-POS
     MOVE JN-KEY-POS(L-B) TO WS-B-POS
     MOVE JN-KEY-LENGTH(L-A) TO WS-A-LENGTH
     MOVE JN-KEY-LENGTH(L-B) TO WS-B-LENGTH
     IF L-ESCAPED = 1
         CALL "JSON-DECODE" USING JSON-DOC WS-A-POS WS-A-LENGTH WS-A-KEY WS-CAP WS-A-DECODED
         CALL "JSON-DECODE" USING JSON-DOC WS-B-POS WS-B-LENGTH WS-B-KEY WS-CAP WS-B-DECODED
         IF WS-A-DECODED = WS-B-DECODED
             IF WS-A-DECODED = 0
                 MOVE 1 TO L-SAME
             ELSE
                 IF WS-A-KEY(1:WS-A-DECODED) = WS-B-KEY(1:WS-A-DECODED)
                     MOVE 1 TO L-SAME
                 END-IF
             END-IF
         END-IF
     ELSE
         IF WS-A-LENGTH = 0
             MOVE 1 TO L-SAME
         ELSE
             IF B-TEXT(WS-A-POS:WS-A-LENGTH) = B-TEXT(WS-B-POS:WS-A-LENGTH)
                 MOVE 1 TO L-SAME
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM JSON-STRICT-SAME-KEY.
