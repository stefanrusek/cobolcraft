*> The node reader of the world generation loaders (see worldgen-types.cob for the type table and CTWORLDGEN.cpy for the
*> store). WG-READ-NODE turns one JSON value of a worldgen file into a tree of nodes of the store, driven by the field
*> list of its type; WG-READ-SPLINE does the same for a spline (10 section 4.3). Every error is printed on standard
*> error as "ERROR registry: <label> <key>: <detail>" (WG-FAIL) and fails the read (status 1); the helpers below read
*> the scalar forms (numbers as the nearest double of their text, integers, strings, enums, anchors, colours, block
*> states). A read that fails leaves nodes behind; the loader (WG-LOAD) takes its counts back.
*> The strict JSON reader of 23 section 3.2 has already accepted every file: the reader here parses it again with the
*> lenient one for its nodes (JSON-PARSE) and finds the text of each number in it (WG-PARSE-DOC), because the double
*> of JN-NUM is not always the nearest one.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-FAIL.
*> USING key (PIC X(112)), detail (PIC X(120)): prints "ERROR registry: <label> <key>: <detail>" and counts the error
*> (RS-ERROR). The label is that of the registry being loaded (WG-LABEL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-MESSAGE             PIC X(200).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-DETAIL               PIC X(120).
 PROCEDURE DIVISION USING L-KEY L-DETAIL.
     MOVE SPACES TO WS-MESSAGE
     STRING FUNCTION TRIM(WG-LABEL) " " FUNCTION TRIM(L-KEY) ": " FUNCTION TRIM(L-DETAIL)
         DELIMITED BY SIZE INTO WS-MESSAGE
     CALL "RS-ERROR" USING WS-MESSAGE
     GOBACK.
 END PROGRAM WG-FAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-ALLOC.
*> USING table (BINARY-LONG: WGK-NODE, WGK-SPLINE, WGK-POINT or WGK-FUNCTION), rows wanted (BINARY-LONG), key (PIC
*> X(112), for the error), first row out (BINARY-LONG), status out (BINARY-LONG, set to 1 and reported when the
*> table of the store (32768, 16384, 24576 or 4096 rows) cannot take the rows; left alone otherwise).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-LIMITS.
    05 FILLER              BINARY-LONG VALUE 32768.
    05 FILLER              BINARY-LONG VALUE 16384.
    05 FILLER              BINARY-LONG VALUE 24576.
    05 FILLER              BINARY-LONG VALUE 4096.
 01 WS-LIMIT-TABLE REDEFINES WS-LIMITS.
    05 WS-LIMIT            BINARY-LONG OCCURS 4 TIMES.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-N L-KEY L-INDEX L-STATUS.
     ADD 1 TO WG-LOAD-GEN
     IF WG-COUNT(L-WHICH) + L-N > WS-LIMIT(L-WHICH)
         MOVE 1 TO L-STATUS
         MOVE "the world generation store is full" TO WS-DETAIL
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
     ELSE
         COMPUTE L-INDEX = WG-COUNT(L-WHICH) + 1
         ADD L-N TO WG-COUNT(L-WHICH)
     END-IF
     GOBACK.
 END PROGRAM WG-ALLOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-PARSE-DOC.
*> USING JSON-DOC, text address (POINTER), length (BINARY-LONG), status out (BINARY-LONG: 0, or 1 when the text does not
*> parse or holds a number of more than 63 bytes): parses the file with the lenient reader and records the start and
*> length of the text of each number node in WG-NUM-POS and WG-NUM-LEN (by node number).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-IN-STRING           BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-SCANNING            BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ADDR                 USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ADDR L-LENGTH L-STATUS.
     SET ADDRESS OF B-TEXT TO L-ADDR
     CALL "JSON-PARSE" USING JSON-DOC B-TEXT L-LENGTH
     MOVE JD-ERROR TO L-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JD-COUNT
         MOVE 0 TO WG-NUM-POS(WS-I) WG-NUM-LEN(WS-I)
     END-PERFORM
     MOVE 1 TO WS-NODE WS-POS
     MOVE 0 TO WS-IN-STRING
     PERFORM UNTIL WS-POS > L-LENGTH
         MOVE B-TEXT(WS-POS:1) TO WS-C
         EVALUATE TRUE
             WHEN WS-IN-STRING = 1 AND WS-C = "\"
                 ADD 2 TO WS-POS
             WHEN WS-IN-STRING = 1 AND WS-C = '"'
                 MOVE 0 TO WS-IN-STRING
                 ADD 1 TO WS-POS
             WHEN WS-IN-STRING = 1
                 ADD 1 TO WS-POS
             WHEN WS-C = '"'
                 MOVE 1 TO WS-IN-STRING
                 ADD 1 TO WS-POS
             WHEN WS-C = "-" OR WS-C IS NUMERIC
                 PERFORM UNTIL WS-NODE > JD-COUNT OR JN-TYPE(WS-NODE) = JT-NUMBER
                     ADD 1 TO WS-NODE
                 END-PERFORM
                 MOVE WS-POS TO WS-START
                 MOVE 1 TO WS-SCANNING
                 PERFORM UNTIL WS-SCANNING = 0
                     ADD 1 TO WS-POS
                     MOVE 0 TO WS-SCANNING
                     IF WS-POS <= L-LENGTH
                         MOVE B-TEXT(WS-POS:1) TO WS-C
                         IF WS-C IS NUMERIC OR WS-C = "+" OR "-" OR "." OR "e" OR "E"
                             MOVE 1 TO WS-SCANNING
                         END-IF
                     END-IF
                 END-PERFORM
                 COMPUTE WS-LENGTH = WS-POS - WS-START
                 IF WS-LENGTH > 63
                     MOVE 1 TO L-STATUS
                 ELSE
                     MOVE WS-START TO WG-NUM-POS(WS-NODE)
                     MOVE WS-LENGTH TO WG-NUM-LEN(WS-NODE)
                 END-IF
                 ADD 1 TO WS-NODE
             WHEN OTHER
                 ADD 1 TO WS-POS
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM WG-PARSE-DOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-DOUBLE.
*> USING JSON-DOC, node, value out (FLOAT-LONG), ok out (BINARY-LONG: 1 when the node is a number): the nearest double
*> of the number's text (cc_f64_from_text), found by WG-PARSE-DOC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-Z                   PIC X(112).
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE L-OK.
     MOVE 0 TO L-VALUE L-OK
     IF JN-TYPE(L-NODE) = JT-NUMBER
         SET ADDRESS OF B-TEXT TO JD-ADDR
         MOVE WG-NUM-POS(L-NODE) TO WS-POS
         MOVE WG-NUM-LEN(L-NODE) TO WS-LENGTH
         MOVE LOW-VALUES TO WS-Z
         MOVE B-TEXT(WS-POS:WS-LENGTH) TO WS-Z(1:WS-LENGTH)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-Z L-VALUE
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM WG-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-INT.
*> USING JSON-DOC, node, value out (BINARY-LONG), ok out (BINARY-LONG: 1 when the node is a number with an integral
*> value that fits 32 bits). The bounds are fields: the literal -2147483648 compares wrongly with a zero double.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 USAGE FLOAT-LONG VALUE -2147483648.
 01 WS-HIGH                USAGE FLOAT-LONG VALUE 2147483647.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE L-OK.
     MOVE 0 TO L-VALUE L-OK
     IF JN-TYPE(L-NODE) = JT-NUMBER
         IF JN-NUM(L-NODE) = FUNCTION INTEGER-PART(JN-NUM(L-NODE))
                 AND JN-NUM(L-NODE) >= WS-LOW AND JN-NUM(L-NODE) <= WS-HIGH
             COMPUTE L-VALUE = JN-NUM(L-NODE)
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WG-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-STRING.
*> USING JSON-DOC, node, limit (BINARY-LONG, at most 199), text out (PIC X(200), space padded), ok out (BINARY-LONG: 1
*> when the node is a string of 1 to limit bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-TEXT                 PIC X(200).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-LIMIT L-TEXT L-OK.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-OK
     COMPUTE WS-CAPACITY = L-LIMIT + 1
     CALL "JSON-STRING" USING JSON-DOC L-NODE L-TEXT WS-CAPACITY WS-LENGTH
     IF WS-LENGTH > 0 AND WS-LENGTH <= L-LIMIT
         MOVE 1 TO L-OK
     ELSE
         MOVE SPACES TO L-TEXT
     END-IF
     GOBACK.
 END PROGRAM WG-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-ENUM.
*> USING text (PIC X(200)), list (PIC X(80): values separated by "|"), code out (BINARY-LONG: the 0-based position of
*> the text in the list, -1 when it is not there).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PART                PIC X(80).
 01 WS-POS                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(200).
 01 L-LIST                 PIC X(80).
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LIST L-CODE.
     MOVE -1 TO L-CODE
     MOVE 1 TO WS-POS
     MOVE 0 TO WS-N
     PERFORM UNTIL WS-POS > 80 OR L-CODE >= 0
         MOVE SPACES TO WS-PART
         UNSTRING L-LIST DELIMITED BY "|" INTO WS-PART WITH POINTER WS-POS
         IF WS-PART = L-TEXT
             MOVE WS-N TO L-CODE
         END-IF
         ADD 1 TO WS-N
     END-PERFORM
     GOBACK.
 END PROGRAM WG-ENUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-ANCHOR.
*> USING JSON-DOC, node, kind out (BINARY-LONG: 1 absolute, 2 above_bottom, 3 below_top, 4 relative_to_sea_level),
*> value out (BINARY-LONG), ok out (BINARY-LONG): a vertical anchor (23 7.3.1) is an object with exactly one of the
*> four keys, its value an integer from -2032 to 2031; a bare integer is an absolute anchor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "absolute".
    05 FILLER              PIC X(32) VALUE "above_bottom".
    05 FILLER              PIC X(32) VALUE "below_top".
    05 FILLER              PIC X(32) VALUE "relative_to_sea_level".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-VALUE-OK            BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KIND L-VALUE L-OK.
     MOVE 0 TO L-KIND L-VALUE L-OK WS-FOUND WS-HIT
     IF JN-TYPE(L-NODE) = JT-NUMBER
         MOVE 1 TO WS-FOUND L-KIND
         MOVE L-NODE TO WS-HIT
     END-IF
     IF JN-TYPE(L-NODE) = JT-OBJECT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE WS-NAME(WS-K) WS-MEMBER
             IF WS-MEMBER > 0
                 ADD 1 TO WS-FOUND
                 MOVE WS-K TO L-KIND
                 MOVE WS-MEMBER TO WS-HIT
             END-IF
         END-PERFORM
     END-IF
     IF WS-FOUND = 1
         CALL "WG-INT" USING JSON-DOC WS-HIT L-VALUE WS-VALUE-OK
         IF WS-VALUE-OK = 1 AND L-VALUE >= -2032 AND L-VALUE <= 2031
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WG-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-COLOUR.
*> USING JSON-DOC, node, value out (BINARY-LONG), ok out (BINARY-LONG): a colour (43 section 5) as an integer (kept as
*> written), a string "#RRGGBB" or a list of three floats from 0 to 1 (floor(v * 255) per channel), the value being
*> the 24 bit RGB number; an object (an attribute value) gives its member "argument" the same way.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX                 PIC X(16) VALUE "0123456789abcdef".
 01 WS-NAME                PIC X(32).
 01 WS-NODE                BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-LIMIT               BINARY-LONG VALUE 7.
 01 WS-OK                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-ELEM                BINARY-LONG.
 01 WS-CHANNEL             BINARY-LONG.
 01 WS-F                   USAGE FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE L-OK.
     MOVE 0 TO L-VALUE L-OK
     MOVE L-NODE TO WS-NODE
     IF JN-TYPE(WS-NODE) = JT-OBJECT
         MOVE "argument" TO WS-NAME
         CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NODE
     END-IF
     IF WS-NODE > 0
         EVALUATE JN-TYPE(WS-NODE)
             WHEN JT-NUMBER
                 CALL "WG-INT" USING JSON-DOC WS-NODE L-VALUE L-OK
             WHEN JT-STRING
                 CALL "WG-STRING" USING JSON-DOC WS-NODE WS-LIMIT WS-TEXT WS-OK
                 IF WS-OK = 1 AND JN-LENGTH(WS-NODE) = 7 AND WS-TEXT(1:1) = "#"
                     MOVE 1 TO L-OK
                     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 7
                         MOVE FUNCTION LOWER-CASE(WS-TEXT(WS-K:1)) TO WS-C
                         MOVE 0 TO WS-D
                         INSPECT WS-HEX TALLYING WS-D FOR CHARACTERS BEFORE INITIAL WS-C
                         IF WS-D > 15
                             MOVE 0 TO L-OK
                         END-IF
                         COMPUTE L-VALUE = L-VALUE * 16 + WS-D
                     END-PERFORM
                 END-IF
             WHEN JT-ARRAY
                 IF JN-COUNT(WS-NODE) = 3
                     MOVE 1 TO L-OK
                     MOVE JN-FIRST(WS-NODE) TO WS-ELEM
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         CALL "WG-DOUBLE" USING JSON-DOC WS-ELEM WS-F WS-FOUND
                         IF WS-FOUND = 0 OR WS-F < 0 OR WS-F > 1
                             MOVE 0 TO L-OK
                             MOVE 0 TO WS-F
                         END-IF
                         COMPUTE WS-CHANNEL = FUNCTION INTEGER(WS-F * 255)
                         COMPUTE L-VALUE = L-VALUE * 256 + WS-CHANNEL
                         MOVE JN-NEXT(WS-ELEM) TO WS-ELEM
                     END-PERFORM
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM WG-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-BLOCK-STATE.
*> USING JSON-DOC, node, limit (BINARY-LONG, at most 199), text out (PIC X(200), space padded), ok out (BINARY-LONG): a
*> block state slot (48 section 2.2): a plain block id string, or an object with the member id (a string, required) and the
*> member properties (an object of string values, optional), as the name followed by " name=value" for each property, at
*> most limit bytes. The keys Name and Properties do not occur in the data (48 section 2.1) and are not read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY-NAME            PIC X(32).
 01 WS-NAME                PIC X(200).
 01 WS-FOUND               BINARY-LONG.
 01 WS-OUT                 PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PROPS               BINARY-LONG.
 01 WS-ELEM                BINARY-LONG.
 01 WS-KEY                 PIC X(200).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               PIC X(200).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-TEXT                 PIC X(200).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-LIMIT L-TEXT L-OK.
     MOVE SPACES TO L-TEXT WS-OUT WS-NAME
     MOVE 0 TO L-OK WS-FOUND
     EVALUATE JN-TYPE(L-NODE)
         WHEN JT-STRING
             CALL "WG-STRING" USING JSON-DOC L-NODE L-LIMIT L-TEXT L-OK
             GOBACK
         WHEN JT-OBJECT
             MOVE "id" TO WS-KEY-NAME
             CALL "RECIPE-GET-TEXT" USING JSON-DOC L-NODE WS-KEY-NAME WS-NAME WS-FOUND
     END-EVALUATE
     IF WS-FOUND = 1
         MOVE 1 TO L-OK WS-PTR
         STRING FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         MOVE "properties" TO WS-KEY-NAME
         CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE WS-KEY-NAME WS-PROPS
         IF WS-PROPS > 0
             IF JN-TYPE(WS-PROPS) = JT-OBJECT
                 MOVE JN-FIRST(WS-PROPS) TO WS-ELEM
                 PERFORM UNTIL WS-ELEM = 0 OR L-OK = 0
                     MOVE SPACES TO WS-KEY WS-VALUE
                     CALL "JSON-KEY" USING JSON-DOC WS-ELEM WS-KEY WS-CAPACITY WS-KEY-LENGTH
                     CALL "JSON-STRING" USING JSON-DOC WS-ELEM WS-VALUE WS-CAPACITY WS-VALUE-LENGTH
                     IF WS-VALUE-LENGTH = 0 OR WS-KEY-LENGTH = 0
                         MOVE 0 TO L-OK
                     ELSE
                         STRING " " WS-KEY(1:WS-KEY-LENGTH) "=" WS-VALUE(1:WS-VALUE-LENGTH)
                             DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
                     END-IF
                     MOVE JN-NEXT(WS-ELEM) TO WS-ELEM
                 END-PERFORM
             ELSE
                 MOVE 0 TO L-OK
             END-IF
         END-IF
         IF WS-PTR - 1 > L-LIMIT
             MOVE 0 TO L-OK
         END-IF
     END-IF
     IF L-OK = 1
         MOVE WS-OUT TO L-TEXT
     END-IF
     GOBACK.
 END PROGRAM WG-BLOCK-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-LIST-TEXT.
*> USING JSON-DOC, node, limit (BINARY-LONG, at most 199), text out (PIC X(200), space padded), ok out (BINARY-LONG): a
*> string, or an array of strings (which may be empty) joined by single spaces, at most limit bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUT                 PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-ELEM                BINARY-LONG.
 01 WS-ITEM                PIC X(200).
 01 WS-ITEM-OK             BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-TEXT                 PIC X(200).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-LIMIT L-TEXT L-OK.
     MOVE SPACES TO L-TEXT WS-OUT
     MOVE 0 TO L-OK
     EVALUATE JN-TYPE(L-NODE)
         WHEN JT-STRING
             CALL "WG-STRING" USING JSON-DOC L-NODE L-LIMIT L-TEXT L-OK
         WHEN JT-ARRAY
             MOVE 1 TO L-OK WS-PTR
             MOVE JN-FIRST(L-NODE) TO WS-ELEM
             PERFORM UNTIL WS-ELEM = 0 OR L-OK = 0
                 CALL "WG-STRING" USING JSON-DOC WS-ELEM L-LIMIT WS-ITEM WS-ITEM-OK
                 IF WS-ITEM-OK = 0
                     MOVE 0 TO L-OK
                 ELSE
                     IF WS-PTR > 1
                         STRING " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
                     END-IF
                     STRING FUNCTION TRIM(WS-ITEM) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
                 END-IF
                 MOVE JN-NEXT(WS-ELEM) TO WS-ELEM
             END-PERFORM
             IF WS-PTR - 1 > L-LIMIT
                 MOVE 0 TO L-OK
             END-IF
             IF L-OK = 1
                 MOVE WS-OUT TO L-TEXT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM WG-LIST-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-MEMBER-NAMED.
*> USING JSON-DOC, object node, name (PIC X(64), space padded: the member names that are density function ids, such as the
*> keys of a spawn_target box (48 section 2.5), are longer than the 32 bytes of RECIPE-MEMBER), member node out (0 when
*> there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-OBJECT               BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-OBJECT L-NAME L-NODE.
     MOVE 0 TO WS-LENGTH
     INSPECT L-NAME TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     CALL "JSON-MEMBER" USING JSON-DOC L-OBJECT L-NAME WS-LENGTH L-NODE
     GOBACK.
 END PROGRAM WG-MEMBER-NAMED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-MEMBER-PATH.
*> USING JSON-DOC, object node, path (PIC X(112): a name, or two names separated by "."), member node out (0 when
*> there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIRST               PIC X(64).
 01 WS-SECOND              PIC X(32).
 01 WS-OUTER               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-PATH                 PIC X(112).
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-PATH L-MEMBER.
     MOVE SPACES TO WS-FIRST WS-SECOND
     UNSTRING L-PATH DELIMITED BY "." INTO WS-FIRST WS-SECOND
     CALL "WG-MEMBER-NAMED" USING JSON-DOC L-NODE WS-FIRST L-MEMBER
     IF WS-SECOND NOT = SPACES
         MOVE L-MEMBER TO WS-OUTER
         MOVE 0 TO L-MEMBER
         IF WS-OUTER > 0
             CALL "RECIPE-MEMBER" USING JSON-DOC WS-OUTER WS-SECOND L-MEMBER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WG-MEMBER-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-READ-FEATURES.
*> USING JSON-DOC, node (the "features" array: an array per decoration step of placed feature ids), key (PIC X(112)),
*> first out (BINARY-LONG: the first node of the chain of domain 14 nodes in listing order, 0 when there is none), ok
*> out (BINARY-LONG: 0 when a value is not of the form), status out (BINARY-LONG: 1 when the store is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-STEP                BINARY-LONG.
 01 WS-OUTER               BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-NODE-TABLE          BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LIMIT               BINARY-LONG VALUE 160.
 01 WS-TEXT                PIC X(200).
 01 WS-TEXT-OK             BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-FIRST                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-FIRST L-OK L-STATUS.
     MOVE 0 TO L-FIRST WS-STEP WS-PREV
     IF JN-TYPE(L-NODE) = JT-ARRAY
         MOVE JN-FIRST(L-NODE) TO WS-OUTER
     ELSE
         MOVE 0 TO WS-OUTER L-OK
     END-IF
     PERFORM UNTIL WS-OUTER = 0 OR L-OK = 0 OR L-STATUS NOT = 0
         IF JN-TYPE(WS-OUTER) = JT-ARRAY
             MOVE JN-FIRST(WS-OUTER) TO WS-INNER
         ELSE
             MOVE 0 TO WS-INNER L-OK
         END-IF
         PERFORM UNTIL WS-INNER = 0 OR L-OK = 0 OR L-STATUS NOT = 0
             CALL "WG-STRING" USING JSON-DOC WS-INNER WS-LIMIT WS-TEXT WS-TEXT-OK
             IF WS-TEXT-OK = 0
                 MOVE 0 TO L-OK
             ELSE
                 CALL "WG-ALLOC" USING WS-NODE-TABLE WS-ONE L-KEY WS-IDX L-STATUS
             END-IF
             IF WS-TEXT-OK = 1 AND L-STATUS = 0
                 INITIALIZE WGN-ROW(WS-IDX)
                 MOVE 14 TO WGN-DOMAIN(WS-IDX)
                 MOVE WS-STEP TO WGN-INT(WS-IDX, 1)
                 MOVE WS-TEXT TO WGN-TEXT-1(WS-IDX)
                 IF WS-PREV = 0
                     MOVE WS-IDX TO L-FIRST
                 ELSE
                     MOVE WS-IDX TO WGN-NEXT(WS-PREV)
                 END-IF
                 MOVE WS-IDX TO WS-PREV
             END-IF
             MOVE JN-NEXT(WS-INNER) TO WS-INNER
         END-PERFORM
         ADD 1 TO WS-STEP
         MOVE JN-NEXT(WS-OUTER) TO WS-OUTER
     END-PERFORM
     GOBACK.
 END PROGRAM WG-READ-FEATURES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-READ-NODE IS RECURSIVE.
*> USING JSON-DOC, node (BINARY-LONG), domain (BINARY-LONG), key (PIC X(112), the element id, for the errors), index
*> out (BINARY-LONG: the node made, 0 on failure), status out (BINARY-LONG: 0, or 1 after an error was reported):
*> reads one value of the domain: a number gives a constant (density, int and float providers), a string a
*> reference (density, surface rule and condition) and an object a node of the type its "type" names (its
*> "predicate_type" for an ore rule test; a height provider without a type is the constant of an anchor; the domains
*> from 10 on have no type). The fields of the type are read in the order of its list (worldgen-types.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-NODE-TABLE          BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LIMIT-160           BINARY-LONG VALUE 160.
 01 WS-LIMIT-112           BINARY-LONG VALUE 112.
 LOCAL-STORAGE SECTION.
 01 LS-MODE                BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-IDX                 BINARY-LONG.
 01 LS-SELF                BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-NAME                PIC X(32).
 01 LS-TYPE-KEY            PIC X(32).
 01 LS-TEXT                PIC X(200).
 01 LS-SPEC                PIC X(640).
 01 LS-SPEC-LENGTH         BINARY-LONG.
 01 LS-POS                 BINARY-LONG.
 01 LS-TOKEN               PIC X(80).
 01 LS-LETTER              PIC X.
 01 LS-UP                  PIC X.
 01 LS-PATH                PIC X(112).
 01 LS-EXTRA               PIC X(80).
 01 LS-ALT                 PIC X(64).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CI                  BINARY-LONG.
 01 LS-NI                  BINARY-LONG.
 01 LS-II                  BINARY-LONG.
 01 LS-TI                  BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-CDOM                BINARY-LONG.
 01 LS-ELEM                BINARY-LONG.
 01 LS-PREV                BINARY-LONG.
 01 LS-NUM                 USAGE FLOAT-LONG.
 01 LS-INT                 BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-LIMIT               BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-DOM-OUT             BINARY-LONG.
 01 LS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-DOMAIN               BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-DOMAIN L-KEY L-INDEX L-STATUS.
     MOVE 0 TO L-INDEX L-STATUS LS-MODE LS-ROW LS-SELF LS-IDX
     MOVE 1 TO LS-OK
     MOVE SPACES TO LS-NAME LS-DETAIL
*>   What kind of value this is (LS-MODE: 0 not allowed here, 1 a bare number, 2 a reference, 3 an object).
     EVALUATE TRUE
         WHEN JN-TYPE(L-NODE) = JT-NUMBER AND (L-DOMAIN = 1 OR L-DOMAIN = 5 OR L-DOMAIN = 6)
             MOVE 1 TO LS-MODE LS-SELF
             MOVE "constant" TO LS-NAME
         WHEN JN-TYPE(L-NODE) = JT-STRING AND (L-DOMAIN = 1 OR L-DOMAIN = 2 OR L-DOMAIN = 3)
             MOVE 2 TO LS-MODE
         WHEN JN-TYPE(L-NODE) = JT-OBJECT
             MOVE 3 TO LS-MODE
             MOVE "-" TO LS-NAME
             IF L-DOMAIN < 10
                 MOVE "type" TO LS-TYPE-KEY
                 IF L-DOMAIN = 4
                     MOVE "predicate_type" TO LS-TYPE-KEY
                 END-IF
                 CALL "RECIPE-GET-TEXT" USING JSON-DOC L-NODE LS-TYPE-KEY LS-TEXT LS-FOUND
                 EVALUATE TRUE
                     WHEN LS-FOUND = 0 AND L-DOMAIN = 7
                         MOVE "constant" TO LS-NAME
                         MOVE 1 TO LS-SELF
                     WHEN LS-FOUND = 0
                         MOVE SPACES TO LS-NAME
                     WHEN LS-TEXT(1:10) = "minecraft:"
                         MOVE LS-TEXT(11:) TO LS-NAME
                     WHEN OTHER
                         MOVE LS-TEXT TO LS-NAME
                 END-EVALUATE
             END-IF
     END-EVALUATE
     IF LS-MODE = 1 OR LS-MODE = 3
         CALL "WG-TYPE-FIND" USING L-DOMAIN LS-NAME LS-ROW
     END-IF
     EVALUATE TRUE
         WHEN LS-MODE = 0
             MOVE "a value of this kind is not allowed here" TO LS-DETAIL
         WHEN LS-MODE NOT = 2 AND LS-ROW = 0
             STRING "unknown type " FUNCTION TRIM(LS-NAME) DELIMITED BY SIZE INTO LS-DETAIL
     END-EVALUATE
     IF LS-DETAIL NOT = SPACES
         CALL "WG-FAIL" USING L-KEY LS-DETAIL
         MOVE 1 TO L-STATUS
     ELSE
         CALL "WG-ALLOC" USING WS-NODE-TABLE WS-ONE L-KEY LS-IDX L-STATUS
     END-IF
     IF L-STATUS = 0
         INITIALIZE WGN-ROW(LS-IDX)
         MOVE L-DOMAIN TO WGN-DOMAIN(LS-IDX)
         MOVE LS-ROW TO WGN-TYPE(LS-IDX)
         MOVE SPACES TO LS-SPEC
         MOVE 0 TO LS-SPEC-LENGTH
         IF LS-MODE = 2
             MOVE "id" TO LS-PATH
             CALL "WG-STRING" USING JSON-DOC L-NODE WS-LIMIT-160 LS-TEXT LS-OK
             MOVE LS-TEXT TO WGN-TEXT-1(LS-IDX)
         ELSE
             CALL "WG-TYPE-AT" USING LS-ROW LS-DOM-OUT LS-NAME LS-SPEC
             IF LS-SPEC NOT = SPACES
                 COMPUTE LS-SPEC-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(LS-SPEC TRAILING))
             END-IF
         END-IF
         MOVE 1 TO LS-POS
         MOVE 0 TO LS-CI LS-NI LS-II LS-TI
         PERFORM UNTIL LS-POS > LS-SPEC-LENGTH OR LS-OK = 0 OR L-STATUS NOT = 0
             MOVE SPACES TO LS-TOKEN LS-PATH LS-EXTRA
             UNSTRING LS-SPEC DELIMITED BY ";" INTO LS-TOKEN WITH POINTER LS-POS
             MOVE LS-TOKEN(1:1) TO LS-LETTER
             MOVE FUNCTION UPPER-CASE(LS-LETTER) TO LS-UP
             UNSTRING LS-TOKEN(3:78) DELIMITED BY "=" INTO LS-PATH LS-EXTRA
             IF LS-SELF = 1
                 MOVE L-NODE TO LS-MEMBER
             ELSE
                 CALL "WG-MEMBER-PATH" USING JSON-DOC L-NODE LS-PATH LS-MEMBER
             END-IF
*>           A G field may name a second spelling of its member after "=" (a spawn_target box of the large biomes
*>           noise settings names the density functions of overworld_large_biomes).
             IF LS-MEMBER = 0 AND LS-UP = "G"
                 MOVE LS-EXTRA TO LS-ALT
                 CALL "WG-MEMBER-NAMED" USING JSON-DOC L-NODE LS-ALT LS-MEMBER
             END-IF
             IF LS-MEMBER = 0
*>               A field that is left out: an error when it is required, else its slot takes the default (the
*>               optional forms in use are D R K Q J L V S U W Y F M, I B E P C and T X H).
                 IF LS-LETTER = LS-UP
                     MOVE 0 TO LS-OK
                 ELSE
                     EVALUATE LS-UP
                         WHEN "D" WHEN "R" WHEN "K" WHEN "Q" WHEN "J" WHEN "L" WHEN "V" WHEN "S" WHEN "U"
                         WHEN "W" WHEN "Y" WHEN "F"
                             ADD 1 TO LS-CI
                         WHEN "M"
                             ADD 1 TO LS-CI LS-II
                         WHEN "G"
                             ADD 2 TO LS-NI
                         WHEN "I"
                             ADD 1 TO LS-II
                             COMPUTE WGN-INT(LS-IDX, LS-II) = FUNCTION NUMVAL(LS-EXTRA)
                         WHEN "B" WHEN "E" WHEN "P"
                             ADD 1 TO LS-II
                         WHEN "C"
                             ADD 1 TO LS-II
                             MOVE -1 TO WGN-INT(LS-IDX, LS-II)
                         WHEN OTHER
                             ADD 1 TO LS-TI
                     END-EVALUATE
                 END-IF
             ELSE
                 EVALUATE LS-UP
                     WHEN "D" WHEN "R" WHEN "K" WHEN "Q" WHEN "J" WHEN "L" WHEN "V"
                         EVALUATE LS-UP
                             WHEN "D"
                                 MOVE 1 TO LS-CDOM
                             WHEN "R"
                                 MOVE 2 TO LS-CDOM
                             WHEN "K"
                                 MOVE 3 TO LS-CDOM
                             WHEN "Q"
                                 MOVE 4 TO LS-CDOM
                             WHEN "J"
                                 MOVE 5 TO LS-CDOM
                             WHEN "L"
                                 MOVE 6 TO LS-CDOM
                             WHEN OTHER
                                 MOVE 7 TO LS-CDOM
                         END-EVALUATE
                         CALL "WG-READ-NODE" USING JSON-DOC LS-MEMBER LS-CDOM L-KEY LS-CHILD L-STATUS
                         ADD 1 TO LS-CI
                         MOVE LS-CHILD TO WGN-CHILD(LS-IDX, LS-CI)
                     WHEN "S" WHEN "U" WHEN "W" WHEN "Y" WHEN "M"
                         EVALUATE LS-UP
                             WHEN "S"
                                 MOVE 2 TO LS-CDOM
                             WHEN "U"
                                 MOVE 4 TO LS-CDOM
                             WHEN "W"
                                 MOVE 10 TO LS-CDOM
                             WHEN "Y"
                                 MOVE 12 TO LS-CDOM
                             WHEN OTHER
                                 MOVE 6 TO LS-CDOM
                         END-EVALUATE
                         ADD 1 TO LS-CI
                         IF JN-TYPE(LS-MEMBER) = JT-ARRAY
                             IF LS-UP = "M"
                                 ADD 1 TO LS-II
                                 MOVE JN-COUNT(LS-MEMBER) TO WGN-INT(LS-IDX, LS-II)
                             END-IF
                             MOVE JN-FIRST(LS-MEMBER) TO LS-ELEM
                             MOVE 0 TO LS-PREV
                             PERFORM UNTIL LS-ELEM = 0 OR L-STATUS NOT = 0
                                 CALL "WG-READ-NODE" USING JSON-DOC LS-ELEM LS-CDOM L-KEY LS-CHILD L-STATUS
                                 IF L-STATUS = 0
                                     IF LS-PREV = 0
                                         MOVE LS-CHILD TO WGN-CHILD(LS-IDX, LS-CI)
                                     ELSE
                                         MOVE LS-CHILD TO WGN-NEXT(LS-PREV)
                                     END-IF
                                     MOVE LS-CHILD TO LS-PREV
                                 END-IF
                                 MOVE JN-NEXT(LS-ELEM) TO LS-ELEM
                             END-PERFORM
                         ELSE
                             MOVE 0 TO LS-OK
                         END-IF
                     WHEN "F"
                         CALL "WG-READ-FEATURES" USING JSON-DOC LS-MEMBER L-KEY LS-CHILD LS-OK L-STATUS
                         ADD 1 TO LS-CI
                         MOVE LS-CHILD TO WGN-CHILD(LS-IDX, LS-CI)
                     WHEN "N"
                         CALL "WG-DOUBLE" USING JSON-DOC LS-MEMBER LS-NUM LS-OK
                         ADD 1 TO LS-NI
                         MOVE LS-NUM TO WGN-NUM(LS-IDX, LS-NI)
                     WHEN "G"
                         MOVE 0 TO LS-A LS-B
                         IF JN-TYPE(LS-MEMBER) = JT-ARRAY AND JN-COUNT(LS-MEMBER) = 2
                             MOVE JN-FIRST(LS-MEMBER) TO LS-ELEM
                             CALL "WG-DOUBLE" USING JSON-DOC LS-ELEM LS-NUM LS-A
                             ADD 1 TO LS-NI
                             MOVE LS-NUM TO WGN-NUM(LS-IDX, LS-NI)
                             MOVE JN-NEXT(LS-ELEM) TO LS-ELEM
                             CALL "WG-DOUBLE" USING JSON-DOC LS-ELEM LS-NUM LS-B
                             ADD 1 TO LS-NI
                             MOVE LS-NUM TO WGN-NUM(LS-IDX, LS-NI)
                         END-IF
                         COMPUTE LS-OK = LS-A * LS-B
                     WHEN "I"
                         CALL "WG-INT" USING JSON-DOC LS-MEMBER LS-INT LS-OK
                         ADD 1 TO LS-II
                         MOVE LS-INT TO WGN-INT(LS-IDX, LS-II)
                     WHEN "B"
                         EVALUATE JN-TYPE(LS-MEMBER)
                             WHEN JT-TRUE
                                 MOVE 1 TO LS-INT
                             WHEN JT-FALSE
                                 MOVE 0 TO LS-INT
                             WHEN OTHER
                                 MOVE 0 TO LS-INT LS-OK
                         END-EVALUATE
                         ADD 1 TO LS-II
                         MOVE LS-INT TO WGN-INT(LS-IDX, LS-II)
                     WHEN "E"
                         MOVE 0 TO LS-INT
                         CALL "WG-STRING" USING JSON-DOC LS-MEMBER WS-LIMIT-112 LS-TEXT LS-OK
                         IF LS-OK = 1
                             CALL "WG-ENUM" USING LS-TEXT LS-EXTRA LS-INT
                             IF LS-INT < 0
                                 MOVE 0 TO LS-OK LS-INT
                             END-IF
                         END-IF
                         ADD 1 TO LS-II
                         MOVE LS-INT TO WGN-INT(LS-IDX, LS-II)
                     WHEN "C"
                         CALL "WG-COLOUR" USING JSON-DOC LS-MEMBER LS-INT LS-OK
                         ADD 1 TO LS-II
                         MOVE LS-INT TO WGN-INT(LS-IDX, LS-II)
                     WHEN "A"
                         CALL "WG-ANCHOR" USING JSON-DOC LS-MEMBER LS-KIND LS-INT LS-OK
                         ADD 1 TO LS-II
                         MOVE LS-KIND TO WGN-INT(LS-IDX, LS-II)
                         ADD 1 TO LS-II
                         MOVE LS-INT TO WGN-INT(LS-IDX, LS-II)
                     WHEN "P"
                         CALL "WG-READ-SPLINE" USING JSON-DOC LS-MEMBER L-KEY LS-CHILD L-STATUS
                         ADD 1 TO LS-II
                         MOVE LS-CHILD TO WGN-INT(LS-IDX, LS-II)
                     WHEN OTHER
*>                       T, X and H: the first text slot holds 160 bytes, the second and third 112.
                         IF LS-TI = 0
                             MOVE WS-LIMIT-160 TO LS-LIMIT
                         ELSE
                             MOVE WS-LIMIT-112 TO LS-LIMIT
                         END-IF
                         EVALUATE LS-UP
                             WHEN "T"
                                 CALL "WG-STRING" USING JSON-DOC LS-MEMBER LS-LIMIT LS-TEXT LS-OK
                             WHEN "X"
                                 CALL "WG-BLOCK-STATE" USING JSON-DOC LS-MEMBER LS-LIMIT LS-TEXT LS-OK
                             WHEN OTHER
                                 CALL "WG-LIST-TEXT" USING JSON-DOC LS-MEMBER LS-LIMIT LS-TEXT LS-OK
                         END-EVALUATE
                         ADD 1 TO LS-TI
                         EVALUATE LS-TI
                             WHEN 1
                                 MOVE LS-TEXT TO WGN-TEXT-1(LS-IDX)
                             WHEN 2
                                 MOVE LS-TEXT TO WGN-TEXT-2(LS-IDX)
                             WHEN OTHER
                                 MOVE LS-TEXT TO WGN-TEXT-3(LS-IDX)
                         END-EVALUATE
                 END-EVALUATE
             END-IF
         END-PERFORM
         IF LS-OK = 0
             MOVE SPACES TO LS-DETAIL
             STRING FUNCTION TRIM(LS-PATH) " is missing or not of the form the type needs" DELIMITED BY SIZE
                 INTO LS-DETAIL
             CALL "WG-FAIL" USING L-KEY LS-DETAIL
             MOVE 1 TO L-STATUS
         END-IF
     END-IF
     IF L-STATUS = 0
         MOVE LS-IDX TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM WG-READ-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-READ-SPLINE IS RECURSIVE.
*> USING JSON-DOC, node, key (PIC X(112)), index out (BINARY-LONG: the row of WSP made, 0 on failure), status out
*> (BINARY-LONG): a spline (10 section 4.3) is a number (a constant) or an object with a coordinate density function
*> and a non-empty array of points, each an object with a location, a derivative and a spline as value; the
*> locations must increase strictly.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-SPLINE-TABLE        BINARY-LONG VALUE 2.
 01 WS-POINT-TABLE         BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DOMAIN              BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-IDX                 BINARY-LONG.
 01 LS-FIRST               BINARY-LONG.
 01 LS-COORD-NODE          BINARY-LONG.
 01 LS-COORD               BINARY-LONG.
 01 LS-POINTS              BINARY-LONG.
 01 LS-ELEM                BINARY-LONG.
 01 LS-POINT               BINARY-LONG.
 01 LS-LOCATION            USAGE FLOAT-LONG.
 01 LS-DERIVATIVE          USAGE FLOAT-LONG.
 01 LS-PREVIOUS            USAGE FLOAT-LONG.
 01 LS-LOCATION-NODE       BINARY-LONG.
 01 LS-DERIVATIVE-NODE     BINARY-LONG.
 01 LS-VALUE-NODE          BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-VALUE               BINARY-LONG.
 01 LS-NAME                PIC X(32).
 01 LS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-INDEX L-STATUS.
     MOVE 0 TO L-INDEX L-STATUS LS-IDX
     MOVE SPACES TO LS-DETAIL
     EVALUATE TRUE
         WHEN JN-TYPE(L-NODE) = JT-NUMBER
             CALL "WG-ALLOC" USING WS-SPLINE-TABLE WS-ONE L-KEY LS-IDX L-STATUS
             IF L-STATUS = 0
                 INITIALIZE WSP-ROW(LS-IDX)
                 CALL "WG-DOUBLE" USING JSON-DOC L-NODE WSP-CONST(LS-IDX) LS-A
             END-IF
         WHEN JN-TYPE(L-NODE) = JT-OBJECT
             MOVE "coordinate" TO LS-NAME
             CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE LS-NAME LS-COORD-NODE
             MOVE "points" TO LS-NAME
             CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE LS-NAME LS-POINTS
             IF LS-COORD-NODE = 0 OR LS-POINTS = 0
                 MOVE 0 TO LS-POINTS
             ELSE
                 IF JN-TYPE(LS-POINTS) NOT = JT-ARRAY OR JN-COUNT(LS-POINTS) = 0
                     MOVE 0 TO LS-POINTS
                 END-IF
             END-IF
             IF LS-POINTS = 0
                 MOVE "a spline needs a coordinate and a list of points" TO LS-DETAIL
                 CALL "WG-FAIL" USING L-KEY LS-DETAIL
                 MOVE 1 TO L-STATUS
             ELSE
                 CALL "WG-READ-NODE" USING JSON-DOC LS-COORD-NODE WS-DOMAIN L-KEY LS-COORD L-STATUS
             END-IF
             IF L-STATUS = 0
                 CALL "WG-ALLOC" USING WS-SPLINE-TABLE WS-ONE L-KEY LS-IDX L-STATUS
             END-IF
             IF L-STATUS = 0
                 CALL "WG-ALLOC" USING WS-POINT-TABLE JN-COUNT(LS-POINTS) L-KEY LS-FIRST L-STATUS
             END-IF
             IF L-STATUS = 0
                 INITIALIZE WSP-ROW(LS-IDX)
                 MOVE LS-COORD TO WSP-COORD(LS-IDX)
                 MOVE LS-FIRST TO WSP-FIRST(LS-IDX)
                 MOVE JN-COUNT(LS-POINTS) TO WSP-N(LS-IDX)
                 MOVE JN-FIRST(LS-POINTS) TO LS-ELEM
                 MOVE LS-FIRST TO LS-POINT
                 PERFORM UNTIL LS-ELEM = 0 OR L-STATUS NOT = 0
                     MOVE "location" TO LS-NAME
                     CALL "RECIPE-MEMBER" USING JSON-DOC LS-ELEM LS-NAME LS-LOCATION-NODE
                     MOVE "derivative" TO LS-NAME
                     CALL "RECIPE-MEMBER" USING JSON-DOC LS-ELEM LS-NAME LS-DERIVATIVE-NODE
                     MOVE "value" TO LS-NAME
                     CALL "RECIPE-MEMBER" USING JSON-DOC LS-ELEM LS-NAME LS-VALUE-NODE
                     MOVE 0 TO LS-A LS-B
                     IF LS-LOCATION-NODE > 0 AND LS-DERIVATIVE-NODE > 0
                         CALL "WG-DOUBLE" USING JSON-DOC LS-LOCATION-NODE LS-LOCATION LS-A
                         CALL "WG-DOUBLE" USING JSON-DOC LS-DERIVATIVE-NODE LS-DERIVATIVE LS-B
                     END-IF
                     EVALUATE TRUE
                         WHEN LS-A = 0 OR LS-B = 0 OR LS-VALUE-NODE = 0
                             MOVE "a point needs a location, a derivative and a value" TO LS-DETAIL
                         WHEN LS-POINT > LS-FIRST AND LS-LOCATION <= LS-PREVIOUS
                             MOVE "the locations of a spline must increase" TO LS-DETAIL
                     END-EVALUATE
                     IF LS-DETAIL NOT = SPACES
                         CALL "WG-FAIL" USING L-KEY LS-DETAIL
                         MOVE 1 TO L-STATUS
                     ELSE
                         CALL "WG-READ-SPLINE" USING JSON-DOC LS-VALUE-NODE L-KEY LS-VALUE L-STATUS
                         MOVE LS-LOCATION TO WPT-LOCATION(LS-POINT) LS-PREVIOUS
                         MOVE LS-DERIVATIVE TO WPT-DERIVATIVE(LS-POINT)
                         MOVE LS-VALUE TO WPT-VALUE(LS-POINT)
                         ADD 1 TO LS-POINT
                         MOVE JN-NEXT(LS-ELEM) TO LS-ELEM
                     END-IF
                 END-PERFORM
             END-IF
         WHEN OTHER
             MOVE "a spline is a number or an object" TO LS-DETAIL
             CALL "WG-FAIL" USING L-KEY LS-DETAIL
             MOVE 1 TO L-STATUS
     END-EVALUATE
     IF L-STATUS = 0
         MOVE LS-IDX TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM WG-READ-SPLINE.
