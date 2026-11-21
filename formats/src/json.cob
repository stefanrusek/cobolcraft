*> JSON parser (RFC 8259) for pack files (08 §2, §4, §5, §7.3, §10.8, §10.10) and the status
*> response (02): JSON-PARSE builds the node table of JSONDOC.cpy without recursion (nesting up to
*> 64 levels, at most JD-MAX-NODES nodes); JSON-STRING and JSON-KEY decode a string or a member key
*> to UTF-8 (every escape, \u with surrogate pairs); JSON-MEMBER, JSON-ELEMENT and JSON-FIND look
*> nodes up (paths a.b[2].c from the root). A node number 0 means "absent".

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-PARSE.
*> USING JSON-DOC, text area, length (BINARY-LONG). Malformed text: JD-ERROR 1, JD-COUNT 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> Modes: 1 a value is expected, 2 a value or "]" (just after "["), 3 a key or "}" (just after
*> "{"), 4 a key (after ","), 5 the colon, 6 "," or the container's close, 7 the end of the text.
 01 WS-MODE                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-N                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-STACK               BINARY-LONG OCCURS 65 TIMES.
 01 WS-KEY-POS             BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 B-TEXT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-TEXT L-LENGTH.
     SET JD-ADDR TO ADDRESS OF L-TEXT
     SET ADDRESS OF B-TEXT TO JD-ADDR
     MOVE L-LENGTH TO JD-LENGTH
     MOVE 0 TO JD-ERROR JD-COUNT WS-DEPTH
     MOVE 1 TO WS-MODE WS-POS
     PERFORM UNTIL JD-ERROR = 1 OR (WS-MODE = 7 AND WS-POS > L-LENGTH)
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
         EVALUATE TRUE
             WHEN WS-POS > L-LENGTH AND WS-MODE = 7
                 CONTINUE
             WHEN WS-POS > L-LENGTH OR WS-MODE = 7
                 MOVE 1 TO JD-ERROR
             WHEN (WS-MODE = 2 AND WS-C = "]") OR ((WS-MODE = 3 OR 6) AND WS-C = "}"
                     AND JN-TYPE(WS-TOP) = JT-OBJECT) OR (WS-MODE = 6 AND WS-C = "]"
                     AND JN-TYPE(WS-TOP) = JT-ARRAY)
                 SUBTRACT 1 FROM WS-DEPTH
                 ADD 1 TO WS-POS
                 MOVE 6 TO WS-MODE
                 IF WS-DEPTH = 0
                     MOVE 7 TO WS-MODE
                 END-IF
             WHEN WS-MODE = 6 AND WS-C = "," AND JN-TYPE(WS-TOP) = JT-OBJECT
                 ADD 1 TO WS-POS
                 MOVE 4 TO WS-MODE
             WHEN WS-MODE = 6 AND WS-C = ","
                 ADD 1 TO WS-POS
                 MOVE 1 TO WS-MODE
             WHEN WS-MODE = 5 AND WS-C = ":"
                 ADD 1 TO WS-POS
                 MOVE 1 TO WS-MODE
             WHEN (WS-MODE = 3 OR 4) AND WS-C = '"'
                 CALL "JSON-SCAN-STRING" USING B-TEXT L-LENGTH WS-POS WS-END JD-ERROR
                 COMPUTE WS-KEY-POS = WS-POS + 1
                 COMPUTE WS-KEY-LENGTH = WS-END - WS-POS - 1
                 COMPUTE WS-POS = WS-END + 1
                 MOVE 5 TO WS-MODE
             WHEN WS-MODE > 2 OR JD-COUNT >= JD-MAX-NODES
                 MOVE 1 TO JD-ERROR
             WHEN OTHER
*>               A value: a new node attached to the open container.
                 ADD 1 TO JD-COUNT
                 MOVE JD-COUNT TO WS-N
                 INITIALIZE JD-NODE(WS-N)
                 MOVE WS-TOP TO JN-PARENT(WS-N)
                 IF WS-TOP > 0
                     IF JN-FIRST(WS-TOP) = 0
                         MOVE WS-N TO JN-FIRST(WS-TOP)
                     ELSE
                         MOVE WS-N TO JN-NEXT(JN-LAST(WS-TOP))
                     END-IF
                     MOVE WS-N TO JN-LAST(WS-TOP)
                     ADD 1 TO JN-COUNT(WS-TOP)
                     IF JN-TYPE(WS-TOP) = JT-OBJECT
                         MOVE WS-KEY-POS TO JN-KEY-POS(WS-N)
                         MOVE WS-KEY-LENGTH TO JN-KEY-LENGTH(WS-N)
                     END-IF
                 END-IF
                 MOVE 6 TO WS-MODE
                 EVALUATE TRUE
                     WHEN WS-C = "{" OR WS-C = "["
                         MOVE JT-OBJECT TO JN-TYPE(WS-N)
                         MOVE 3 TO WS-MODE
                         IF WS-C = "["
                             MOVE JT-ARRAY TO JN-TYPE(WS-N)
                             MOVE 2 TO WS-MODE
                         END-IF
                         ADD 1 TO WS-POS
                         ADD 1 TO WS-DEPTH
                         IF WS-DEPTH > 64
                             MOVE 1 TO JD-ERROR
                         ELSE
                             MOVE WS-N TO WS-STACK(WS-DEPTH)
                         END-IF
                     WHEN WS-C = '"'
                         MOVE JT-STRING TO JN-TYPE(WS-N)
                         CALL "JSON-SCAN-STRING" USING B-TEXT L-LENGTH WS-POS WS-END JD-ERROR
                         COMPUTE JN-POS(WS-N) = WS-POS + 1
                         COMPUTE JN-LENGTH(WS-N) = WS-END - WS-POS - 1
                         COMPUTE WS-POS = WS-END + 1
                     WHEN WS-C = "t" AND B-TEXT(WS-POS:4) = "true" AND WS-POS + 3 <= L-LENGTH
                         MOVE JT-TRUE TO JN-TYPE(WS-N)
                         ADD 4 TO WS-POS
                     WHEN WS-C = "f" AND B-TEXT(WS-POS:5) = "false" AND WS-POS + 4 <= L-LENGTH
                         MOVE JT-FALSE TO JN-TYPE(WS-N)
                         ADD 5 TO WS-POS
                     WHEN WS-C = "n" AND B-TEXT(WS-POS:4) = "null" AND WS-POS + 3 <= L-LENGTH
                         MOVE JT-NULL TO JN-TYPE(WS-N)
                         ADD 4 TO WS-POS
                     WHEN WS-C = "-" OR WS-C IS NUMERIC
                         MOVE JT-NUMBER TO JN-TYPE(WS-N)
                         CALL "JSON-SCAN-NUMBER" USING B-TEXT L-LENGTH WS-POS JN-NUM(WS-N) JD-ERROR
                     WHEN OTHER
                         MOVE 1 TO JD-ERROR
                 END-EVALUATE
                 IF WS-DEPTH = 0 AND WS-MODE = 6
                     MOVE 7 TO WS-MODE
                 END-IF
         END-EVALUATE
     END-PERFORM
     IF JD-ERROR = 1
         MOVE 0 TO JD-COUNT
     END-IF
     GOBACK.
 END PROGRAM JSON-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-SCAN-STRING.
*> USING text, length, position of the opening quote, position of the closing quote out, error
*> flag (set when the string is unterminated, has a control character or a bad escape).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HEXDIGITS           PIC X(22) VALUE "0123456789abcdefABCDEF".
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1073741824).
 01 L-LENGTH               BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-ERROR                PIC 9.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-START L-END L-ERROR.
     COMPUTE WS-K = L-START + 1
     MOVE 0 TO L-END
     PERFORM UNTIL L-END > 0 OR L-ERROR = 1
         EVALUATE TRUE
             WHEN WS-K > L-LENGTH OR L-TEXT(WS-K:1) < SPACE
                 MOVE 1 TO L-ERROR
             WHEN L-TEXT(WS-K:1) = '"'
                 MOVE WS-K TO L-END
             WHEN L-TEXT(WS-K:1) = "\" AND WS-K < L-LENGTH
                 ADD 1 TO WS-K
                 EVALUATE TRUE
                     WHEN L-TEXT(WS-K:1) = '"' OR "\" OR "/" OR "b" OR "f" OR "n" OR "r" OR "t"
                         ADD 1 TO WS-K
                     WHEN L-TEXT(WS-K:1) = "u" AND WS-K + 4 <= L-LENGTH
                         PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 4
                             MOVE 0 TO WS-COUNT
                             INSPECT WS-HEXDIGITS TALLYING WS-COUNT FOR ALL L-TEXT(WS-K + WS-H:1)
                             IF WS-COUNT = 0
                                 MOVE 1 TO L-ERROR
                             END-IF
                         END-PERFORM
                         ADD 5 TO WS-K
                     WHEN OTHER
                         MOVE 1 TO L-ERROR
                 END-EVALUATE
             WHEN OTHER
                 ADD 1 TO WS-K
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-SCAN-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-SCAN-NUMBER.
*> USING text, length, position (moved past the number), value out (FLOAT-LONG), error flag:
*> -? (0 | [1-9][0-9]*) (. [0-9]+)? ([eE] [+-]? [0-9]+)?
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIGN                BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-ESIGN               BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-MANT                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1073741824).
 01 L-LENGTH               BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-ERROR                PIC 9.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-POS L-VALUE L-ERROR.
     MOVE 1 TO WS-SIGN WS-ESIGN
     MOVE 0 TO WS-DIGITS WS-SCALE WS-EXP WS-MANT
     IF L-TEXT(L-POS:1) = "-"
         MOVE -1 TO WS-SIGN
         ADD 1 TO L-POS
     END-IF
     PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
         COMPUTE WS-MANT = WS-MANT * 10 + FUNCTION NUMVAL(L-TEXT(L-POS:1))
         ADD 1 TO WS-DIGITS L-POS
     END-PERFORM
     IF WS-DIGITS = 0
         MOVE 1 TO L-ERROR
     END-IF
     IF L-POS <= L-LENGTH AND L-TEXT(L-POS:1) = "."
         ADD 1 TO L-POS
         MOVE 0 TO WS-DIGITS
         PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
             COMPUTE WS-MANT = WS-MANT * 10 + FUNCTION NUMVAL(L-TEXT(L-POS:1))
             ADD 1 TO WS-DIGITS WS-SCALE L-POS
         END-PERFORM
         IF WS-DIGITS = 0
             MOVE 1 TO L-ERROR
         END-IF
     END-IF
     IF L-POS <= L-LENGTH AND (L-TEXT(L-POS:1) = "e" OR "E")
         ADD 1 TO L-POS
         IF L-POS <= L-LENGTH AND (L-TEXT(L-POS:1) = "+" OR "-")
             IF L-TEXT(L-POS:1) = "-"
                 MOVE -1 TO WS-ESIGN
             END-IF
             ADD 1 TO L-POS
         END-IF
         MOVE 0 TO WS-DIGITS
         PERFORM UNTIL L-POS > L-LENGTH OR L-TEXT(L-POS:1) IS NOT NUMERIC
             COMPUTE WS-EXP = WS-EXP * 10 + FUNCTION NUMVAL(L-TEXT(L-POS:1))
             ADD 1 TO WS-DIGITS L-POS
         END-PERFORM
         IF WS-DIGITS = 0
             MOVE 1 TO L-ERROR
         END-IF
     END-IF
     COMPUTE L-VALUE = WS-SIGN * WS-MANT * (10 ** (WS-ESIGN * WS-EXP - WS-SCALE))
     GOBACK.
 END PROGRAM JSON-SCAN-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-FIND.
*> USING JSON-DOC, path area, path length, node out: follows the path from the root (node 1):
*> member names separated by "." (an empty name is the empty key), array indexes as [n]. 0 when
*> any step is absent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-NAME                PIC X(1024).
 01 B-PATH                 PIC X(1024) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-PATH                 PIC X.
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-PATH L-PATH-LENGTH L-NODE.
     SET ADDRESS OF B-PATH TO ADDRESS OF L-PATH
     MOVE FUNCTION MIN(JD-COUNT, 1) TO L-NODE
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > L-PATH-LENGTH OR L-NODE = 0
         EVALUATE TRUE
             WHEN B-PATH(WS-I:1) = "."
                 ADD 1 TO WS-I
*>               A step with no name ("a..b", or a final ".") is the member with the empty key.
                 IF WS-I > L-PATH-LENGTH OR B-PATH(WS-I:1) = "."
                     MOVE 0 TO WS-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-LENGTH WS-NEXT
                     MOVE WS-NEXT TO L-NODE
                 END-IF
             WHEN B-PATH(WS-I:1) = "["
                 MOVE 0 TO WS-INDEX
                 ADD 1 TO WS-I
                 PERFORM UNTIL WS-I > L-PATH-LENGTH OR B-PATH(WS-I:1) = "]"
                     COMPUTE WS-INDEX = WS-INDEX * 10 + FUNCTION NUMVAL(B-PATH(WS-I:1))
                     ADD 1 TO WS-I
                 END-PERFORM
                 ADD 1 TO WS-I
                 CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-INDEX WS-NEXT
                 MOVE WS-NEXT TO L-NODE
             WHEN OTHER
                 MOVE WS-I TO WS-START
                 PERFORM UNTIL WS-I > L-PATH-LENGTH OR B-PATH(WS-I:1) = "." OR "["
                     ADD 1 TO WS-I
                 END-PERFORM
                 COMPUTE WS-LENGTH = WS-I - WS-START
                 MOVE B-PATH(WS-START:WS-LENGTH) TO WS-NAME
                 CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-LENGTH WS-NEXT
                 MOVE WS-NEXT TO L-NODE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-ELEMENT.
*> USING JSON-DOC, array node, index (0-based), element node out (0 when absent; it may be the
*> same item as the array node).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ELEMENT              BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-INDEX L-ELEMENT.
     MOVE 0 TO WS-FIRST
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-ARRAY
             MOVE JN-FIRST(L-NODE) TO WS-FIRST
         END-IF
     END-IF
     MOVE WS-FIRST TO L-ELEMENT
     IF WS-FIRST > 0
        PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-INDEX OR L-ELEMENT = 0
                 MOVE JN-NEXT(L-ELEMENT) TO L-ELEMENT
             END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM JSON-ELEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-MEMBER.
*> USING JSON-DOC, object node, key area, key length, member node out (0 when the node is no
*> object or has no such member; the last of duplicate keys wins; it may be the same item as the
*> object node).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 PIC X(512).
 01 WS-CAP                 BINARY-LONG VALUE 512.
 01 WS-LENGTH              BINARY-LONG.
 01 B-KEY                  PIC X(512) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X.
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-KEY-LENGTH L-MEMBER.
     SET ADDRESS OF B-KEY TO ADDRESS OF L-KEY
     MOVE 0 TO WS-N
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-OBJECT
             MOVE JN-FIRST(L-NODE) TO WS-N
         END-IF
     END-IF
     MOVE 0 TO L-MEMBER
     PERFORM UNTIL WS-N = 0
         CALL "JSON-DECODE" USING JSON-DOC JN-KEY-POS(WS-N) JN-KEY-LENGTH(WS-N) WS-KEY WS-CAP
             WS-LENGTH
         IF WS-LENGTH = L-KEY-LENGTH
             IF WS-LENGTH = 0
                 MOVE WS-N TO L-MEMBER
             ELSE
                 IF WS-KEY(1:WS-LENGTH) = B-KEY(1:WS-LENGTH)
                     MOVE WS-N TO L-MEMBER
                 END-IF
             END-IF
         END-IF
         MOVE JN-NEXT(WS-N) TO WS-N
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-STRING.
*> USING JSON-DOC, string node, out area, capacity, length out (0 when the node is no string).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-OUT                  PIC X.
 01 L-CAP                  BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-OUT L-CAP L-LENGTH.
     MOVE 0 TO L-LENGTH
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-STRING
             CALL "JSON-DECODE" USING JSON-DOC JN-POS(L-NODE) JN-LENGTH(L-NODE) L-OUT L-CAP
                 L-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM JSON-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-KEY.
*> USING JSON-DOC, member node, out area, capacity, length out: the member's key.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-OUT                  PIC X.
 01 L-CAP                  BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-OUT L-CAP L-LENGTH.
     CALL "JSON-DECODE" USING JSON-DOC JN-KEY-POS(L-NODE) JN-KEY-LENGTH(L-NODE) L-OUT L-CAP
         L-LENGTH
     GOBACK.
 END PROGRAM JSON-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-DECODE.
*> USING JSON-DOC, 1-based text offset, raw length, out area, capacity, length out: decodes the
*> escapes of a JSON string body to UTF-8 (a lone surrogate becomes U+FFFD); stops at the capacity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-UTF8                PIC X(4).
 01 WS-C                   PIC X.
 01 B-TEXT                 PIC X(1073741824) BASED.
 01 B-OUT                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-POS                  BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 01 L-OUT                  PIC X.
 01 L-CAP                  BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-POS L-RAW L-OUT L-CAP L-LENGTH.
     SET ADDRESS OF B-TEXT TO JD-ADDR
     SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
     MOVE 0 TO L-LENGTH
     MOVE L-POS TO WS-K
     COMPUTE WS-END = L-POS + L-RAW
     PERFORM UNTIL WS-K >= WS-END
         MOVE B-TEXT(WS-K:1) TO WS-C
         MOVE 1 TO WS-BYTES
         MOVE WS-C TO WS-UTF8(1:1)
         ADD 1 TO WS-K
         IF WS-C = "\"
             MOVE B-TEXT(WS-K:1) TO WS-C
             ADD 1 TO WS-K
             EVALUATE WS-C
                 WHEN "b"
                     MOVE X"08" TO WS-UTF8(1:1)
                 WHEN "f"
                     MOVE X"0C" TO WS-UTF8(1:1)
                 WHEN "n"
                     MOVE X"0A" TO WS-UTF8(1:1)
                 WHEN "r"
                     MOVE X"0D" TO WS-UTF8(1:1)
                 WHEN "t"
                     MOVE X"09" TO WS-UTF8(1:1)
                 WHEN "u"
                     CALL "JSON-HEX4" USING B-TEXT(WS-K:4) WS-CP
                     ADD 4 TO WS-K
                     IF WS-CP >= 55296 AND WS-CP <= 57343
                         MOVE 65533 TO WS-LOW
                         IF WS-CP <= 56319 AND WS-K + 5 < WS-END AND B-TEXT(WS-K:2) = "\u"
                             CALL "JSON-HEX4" USING B-TEXT(WS-K + 2:4) WS-LOW
                         END-IF
                         IF WS-LOW >= 56320 AND WS-LOW <= 57343
                             COMPUTE WS-CP = 65536 + (WS-CP - 55296) * 1024 + WS-LOW - 56320
                             ADD 6 TO WS-K
                         ELSE
                             MOVE 65533 TO WS-CP
                         END-IF
                     END-IF
                     CALL "UTF8-ENCODE" USING WS-CP WS-UTF8 WS-BYTES
                 WHEN OTHER
                     MOVE WS-C TO WS-UTF8(1:1)
             END-EVALUATE
         END-IF
         IF L-LENGTH + WS-BYTES <= L-CAP
             MOVE WS-UTF8(1:WS-BYTES) TO B-OUT(L-LENGTH + 1:WS-BYTES)
             ADD WS-BYTES TO L-LENGTH
         ELSE
             MOVE WS-END TO WS-K
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-HEX4.
*> USING four hex digits (PIC X(4)), value out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-HEXDIGITS           PIC X(32) VALUE "0123456789abcdef0123456789ABCDEF".
 LINKAGE SECTION.
 01 L-HEX                  PIC X(4).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-HEX L-VALUE.
     MOVE 0 TO L-VALUE
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 4
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-HEXDIGITS(WS-D:1) = L-HEX(WS-H:1)
             CONTINUE
         END-PERFORM
         COMPUTE L-VALUE = L-VALUE * 16 + FUNCTION MOD(WS-D - 1, 16)
     END-PERFORM
     GOBACK.
 END PROGRAM JSON-HEX4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UTF8-ENCODE.
*> USING code point (BINARY-LONG, 0 to 1114111), bytes out (PIC X(4)), byte count out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-CHAR UNSIGNED OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CP                   BINARY-LONG.
 01 L-OUT                  PIC X(4).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CP L-OUT L-COUNT.
     EVALUATE TRUE
         WHEN L-CP < 128
             MOVE 1 TO L-COUNT
             MOVE L-CP TO WS-B(1)
         WHEN L-CP < 2048
             MOVE 2 TO L-COUNT
             COMPUTE WS-B(1) = 192 + L-CP / 64
             COMPUTE WS-B(2) = 128 + FUNCTION MOD(L-CP, 64)
         WHEN L-CP < 65536
             MOVE 3 TO L-COUNT
             COMPUTE WS-B(1) = 224 + L-CP / 4096
             COMPUTE WS-B(2) = 128 + FUNCTION MOD(L-CP / 64, 64)
             COMPUTE WS-B(3) = 128 + FUNCTION MOD(L-CP, 64)
         WHEN OTHER
             MOVE 4 TO L-COUNT
             COMPUTE WS-B(1) = 240 + L-CP / 262144
             COMPUTE WS-B(2) = 128 + FUNCTION MOD(L-CP / 4096, 64)
             COMPUTE WS-B(3) = 128 + FUNCTION MOD(L-CP / 64, 64)
             COMPUTE WS-B(4) = 128 + FUNCTION MOD(L-CP, 64)
     END-EVALUATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         MOVE FUNCTION CHAR(WS-B(WS-I) + 1) TO L-OUT(WS-I:1)
     END-PERFORM
     GOBACK.
 END PROGRAM UTF8-ENCODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UTF8-DECODE.
*> USING text area, length, position (1-based, moved past the character), code point out: the
*> UTF-8 character at the position. A byte that starts no valid sequence (or a sequence cut by the
*> end) gives U+FFFD and moves one byte.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 B-TEXT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-CP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-POS L-CP.
     SET ADDRESS OF B-TEXT TO ADDRESS OF L-TEXT
     COMPUTE WS-B = FUNCTION ORD(B-TEXT(L-POS:1)) - 1
     EVALUATE TRUE
         WHEN WS-B < 128
             MOVE 0 TO WS-N
             MOVE WS-B TO L-CP
         WHEN WS-B >= 240 AND WS-B < 248
             MOVE 3 TO WS-N
             COMPUTE L-CP = WS-B - 240
         WHEN WS-B >= 224 AND WS-B < 240
             MOVE 2 TO WS-N
             COMPUTE L-CP = WS-B - 224
         WHEN WS-B >= 192 AND WS-B < 224
             MOVE 1 TO WS-N
             COMPUTE L-CP = WS-B - 192
         WHEN OTHER
             MOVE -1 TO WS-N
     END-EVALUATE
     IF WS-N > 0 AND L-POS + WS-N > L-LENGTH
         MOVE -1 TO WS-N
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         COMPUTE WS-C = FUNCTION ORD(B-TEXT(L-POS + WS-K:1)) - 1
         IF WS-C < 128 OR WS-C >= 192
             MOVE -1 TO WS-N
         ELSE
             COMPUTE L-CP = L-CP * 64 + WS-C - 128
         END-IF
     END-PERFORM
     IF WS-N < 0
         MOVE 65533 TO L-CP
         MOVE 0 TO WS-N
     END-IF
     COMPUTE L-POS = L-POS + WS-N + 1
     GOBACK.
 END PROGRAM UTF8-DECODE.
