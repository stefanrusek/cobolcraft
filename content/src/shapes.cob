*> The engine of the data shape loaders (docs/protocol/35 to 39 data pack file shapes; docs/protocol/23 sections 1, 2.1 and 3
*> for the files, their identifiers, the strict reader and the failure rule). A loader of a document part (load-35-1.cob and
*> the others) registers the types of its part with SHAPE-TYPE-ADD, then SHAPE-BEGIN, one SHAPE-LOAD per registry it owns
*> and SHAPE-END. The files of a registry come through the registry loader of registry.cob (listing order, identifier
*> rules, JSON-STRICT); each is checked against the shape of its type (the field list forms of CTSHAPE.cpy) and, when it
*> passes, kept as an element row of the store. Every error is printed on standard error as "ERROR registry: <registry>
*> <key>: <detail>"; any error fails the load as a whole (23 section 3.5): the status of SHAPE-END is CT-BAD-DATA and the
*> elements since SHAPE-BEGIN are taken back. Members the shapes do not name are ignored (the codecs of the documents
*> ignore unknown members). An object of a group whose type nobody registered is an error only for a strict load (the
*> top-level file) and is accepted when it is nested inside another shape.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-FREE.
*> No parameters: forgets every type row and frees every element. Safe with nothing loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SH-ELEMENT-COUNT
         FREE SH-E-ADDR(WS-I)
     END-PERFORM
     MOVE 0 TO SH-ELEMENT-COUNT SH-TYPE-COUNT SH-MARK
     GOBACK.
 END PROGRAM SHAPE-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-TYPE-FIND.
*> USING group (PIC X(24)), type (PIC X(48), without "minecraft:"), row out (BINARY-LONG, 0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-GROUP                PIC X(24).
 01 L-TYPE                 PIC X(48).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUP L-TYPE L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SH-TYPE-COUNT OR L-ROW > 0
         IF SH-T-GROUP(WS-I) = L-GROUP AND SH-T-NAME(WS-I) = L-TYPE
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHAPE-TYPE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-TYPE-ADD.
*> USING group (PIC X(24)), type (PIC X(48); "-" for the shape of a group whose objects have no "type"; a "minecraft:"
*> prefix is dropped), fields (PIC X(600), the list of CTSHAPE.cpy), status out (BINARY-LONG: 0, or 1 when the 2048
*> rows are used). A row of a group and type that exists is left as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-TYPE                PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-GROUP                PIC X(24).
 01 L-TYPE                 PIC X(48).
 01 L-FIELDS               PIC X(600).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUP L-TYPE L-FIELDS L-STATUS.
     MOVE 0 TO L-STATUS
     MOVE L-TYPE TO WS-TYPE
     IF L-TYPE(1:10) = "minecraft:"
         MOVE SPACES TO WS-TYPE
         MOVE L-TYPE(11:) TO WS-TYPE
     END-IF
     CALL "SHAPE-TYPE-FIND" USING L-GROUP WS-TYPE WS-ROW
     IF WS-ROW = 0
         IF SH-TYPE-COUNT >= SH-MAX-TYPES
             MOVE 1 TO L-STATUS
         ELSE
             ADD 1 TO SH-TYPE-COUNT
             MOVE L-GROUP TO SH-T-GROUP(SH-TYPE-COUNT)
             MOVE WS-TYPE TO SH-T-NAME(SH-TYPE-COUNT)
             MOVE L-FIELDS TO SH-T-FIELDS(SH-TYPE-COUNT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHAPE-TYPE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-REGISTER.
*> USING rows (the rows one after the other, each a group PIC X(24), a type PIC X(48) and a field list PIC X(600); a
*> loader keeps them in WORKING-STORAGE as FILLER values), count (BINARY-LONG): SHAPE-TYPE-ADD for each row. A full
*> table counts one load error (RS-ERROR) for SHAPE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 B-ROWS BASED.
    05 BR-ROW OCCURS 256 TIMES.
       10 BR-GROUP         PIC X(24).
       10 BR-TYPE          PIC X(48).
       10 BR-FIELDS        PIC X(600).
 01 WS-I                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-MESSAGE             PIC X(200).
 LINKAGE SECTION.
 01 L-ROWS                 PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROWS L-COUNT.
     SET ADDRESS OF B-ROWS TO ADDRESS OF L-ROWS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "SHAPE-TYPE-ADD" USING BR-GROUP(WS-I) BR-TYPE(WS-I) BR-FIELDS(WS-I) WS-STATUS
         IF WS-STATUS NOT = 0
             MOVE "the shape type table is full" TO WS-MESSAGE
             CALL "RS-ERROR" USING WS-MESSAGE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHAPE-REGISTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-ID.
*> USING text (PIC X(200), an identifier up to the first space), tag mark allowed (BINARY-LONG: 1 when a leading "#" is
*> part of the form), ok out (BINARY-LONG: 1 valid, 0 not): 23 section 1: "namespace:path" or "path", at most 64 bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-PART                PIC X(64).
 01 WS-PART-LENGTH         BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(200).
 01 L-HASH                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-HASH L-OK.
     MOVE 1 TO L-OK WS-START
     MOVE 0 TO WS-LENGTH WS-COLON
     INSPECT L-TEXT TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     IF L-HASH = 1 AND L-TEXT(1:1) = "#"
         MOVE 2 TO WS-START
     END-IF
     IF WS-LENGTH > 64 OR WS-LENGTH < WS-START
         MOVE 0 TO L-OK
     END-IF
     IF L-OK = 1
         INSPECT L-TEXT(WS-START:WS-LENGTH - WS-START + 1) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
         IF WS-COLON < WS-LENGTH - WS-START + 1
             MOVE SPACES TO WS-PART
             MOVE L-TEXT(WS-START:WS-COLON) TO WS-PART
             MOVE WS-COLON TO WS-PART-LENGTH
             MOVE 1 TO WS-MODE
             CALL "RS-ID-VALID" USING WS-PART WS-PART-LENGTH WS-MODE
             MOVE WS-MODE TO L-OK
             COMPUTE WS-START = WS-START + WS-COLON + 1
         END-IF
     END-IF
     IF L-OK = 1
         COMPUTE WS-PART-LENGTH = WS-LENGTH - WS-START + 1
         MOVE SPACES TO WS-PART
         IF WS-PART-LENGTH > 0
             MOVE L-TEXT(WS-START:WS-PART-LENGTH) TO WS-PART
         END-IF
         MOVE 2 TO WS-MODE
         CALL "RS-ID-VALID" USING WS-PART WS-PART-LENGTH WS-MODE
         MOVE WS-MODE TO L-OK
     END-IF
     GOBACK.
 END PROGRAM SHAPE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-RANGE.
*> USING arg (PIC X(40): "min..max", either side may be empty, or spaces), member name (PIC X(32)), value (FLOAT-LONG),
*> detail in/out (PIC X(120): set when the value is out of range).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO                  PIC X(24).
 01 WS-HI                  PIC X(24).
 01 WS-BOUND               USAGE FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ARG                  PIC X(40).
 01 L-NAME                 PIC X(32).
 01 L-NUM                  USAGE FLOAT-LONG.
 01 L-DETAIL               PIC X(120).
 PROCEDURE DIVISION USING L-ARG L-NAME L-NUM L-DETAIL.
     IF L-ARG NOT = SPACES
         MOVE SPACES TO WS-LO WS-HI
         UNSTRING L-ARG DELIMITED BY ".." INTO WS-LO WS-HI
         IF WS-LO NOT = SPACES
             COMPUTE WS-BOUND = FUNCTION NUMVAL(WS-LO)
             IF L-NUM < WS-BOUND
                 STRING "member " FUNCTION TRIM(L-NAME) " is below " FUNCTION TRIM(WS-LO)
                     DELIMITED BY SIZE INTO L-DETAIL
             END-IF
         END-IF
         IF WS-HI NOT = SPACES
             COMPUTE WS-BOUND = FUNCTION NUMVAL(WS-HI)
             IF L-NUM > WS-BOUND
                 STRING "member " FUNCTION TRIM(L-NAME) " is above " FUNCTION TRIM(WS-HI)
                     DELIMITED BY SIZE INTO L-DETAIL
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHAPE-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-VALUE IS RECURSIVE.
*> USING JSON-DOC, node, form letter (PIC X, capital), arg (PIC X(40)), member name (PIC X(32)), key (PIC X(64)), status
*> (BINARY-LONG, set to 1 after an error was reported, else left alone): checks one value against one form of CTSHAPE.cpy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NO-STRICT           BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 01 WS-D                   PIC X VALUE "D".
 01 WS-T                   PIC X VALUE "T".
 01 WS-R                   PIC X VALUE "R".
 LOCAL-STORAGE SECTION.
 01 LS-DETAIL              PIC X(120).
 01 LS-TEXT                PIC X(200).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-LO                  PIC X(24).
 01 LS-HI                  PIC X(24).
 01 LS-NUM                 USAGE FLOAT-LONG.
 01 LS-BOUND               USAGE FLOAT-LONG.
 01 LS-POS                 BINARY-LONG.
 01 LS-TOKEN               PIC X(40).
 01 LS-NAME                PIC X(32).
 01 LS-TYPE                PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-LETTER               PIC X.
 01 L-ARG                  PIC X(40).
 01 L-NAME                 PIC X(32).
 01 L-KEY                  PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-LETTER L-ARG L-NAME L-KEY L-STATUS.
     MOVE SPACES TO LS-DETAIL LS-TEXT
     EVALUATE L-LETTER
         WHEN "S"
             IF JN-TYPE(L-NODE) NOT = JT-STRING
                 STRING "member " FUNCTION TRIM(L-NAME) " must be a string" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "D"
             MOVE 0 TO LS-OK
             IF JN-TYPE(L-NODE) = JT-STRING
                 CALL "JSON-STRING" USING JSON-DOC L-NODE LS-TEXT WS-CAPACITY LS-LENGTH
                 CALL "SHAPE-ID" USING LS-TEXT WS-ZERO LS-OK
             END-IF
             IF LS-OK = 0
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an identifier" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "I"
             MOVE JN-NUM(L-NODE) TO LS-NUM
             IF JN-TYPE(L-NODE) NOT = JT-NUMBER
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an integer" DELIMITED BY SIZE INTO LS-DETAIL
             ELSE
                 IF LS-NUM NOT = FUNCTION INTEGER-PART(LS-NUM)
                     STRING "member " FUNCTION TRIM(L-NAME) " must be an integer" DELIMITED BY SIZE INTO LS-DETAIL
                 END-IF
             END-IF
             IF LS-DETAIL = SPACES
                 CALL "SHAPE-RANGE" USING L-ARG L-NAME LS-NUM LS-DETAIL
             END-IF
         WHEN "N"
             IF JN-TYPE(L-NODE) NOT = JT-NUMBER
                 STRING "member " FUNCTION TRIM(L-NAME) " must be a number" DELIMITED BY SIZE INTO LS-DETAIL
             ELSE
                 MOVE JN-NUM(L-NODE) TO LS-NUM
                 CALL "SHAPE-RANGE" USING L-ARG L-NAME LS-NUM LS-DETAIL
             END-IF
         WHEN "B"
             IF JN-TYPE(L-NODE) NOT = JT-TRUE AND JN-TYPE(L-NODE) NOT = JT-FALSE
                 STRING "member " FUNCTION TRIM(L-NAME) " must be a boolean" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "E"
             MOVE 0 TO LS-OK
             IF JN-TYPE(L-NODE) = JT-STRING
                 CALL "JSON-STRING" USING JSON-DOC L-NODE LS-TEXT WS-CAPACITY LS-LENGTH
                 MOVE LS-TEXT TO LS-TYPE
                 IF LS-TEXT(1:10) = "minecraft:"
                     MOVE SPACES TO LS-TYPE
                     MOVE LS-TEXT(11:) TO LS-TYPE
                 END-IF
                 MOVE 1 TO LS-POS
                 PERFORM UNTIL LS-POS > 40 OR LS-OK = 1
                     MOVE SPACES TO LS-TOKEN
                     UNSTRING L-ARG DELIMITED BY "|" INTO LS-TOKEN WITH POINTER LS-POS
                     IF LS-TOKEN NOT = SPACES AND LS-TOKEN = LS-TYPE
                         MOVE 1 TO LS-OK
                     END-IF
                 END-PERFORM
             END-IF
             IF LS-OK = 0
                 STRING "member " FUNCTION TRIM(L-NAME) " is not one of " FUNCTION TRIM(L-ARG)
                     DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "O"
             IF JN-TYPE(L-NODE) NOT = JT-OBJECT
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an object" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "A"
             IF JN-TYPE(L-NODE) NOT = JT-ARRAY
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an array" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "T"
             CALL "SHAPE-VALIDATE" USING JSON-DOC L-NODE L-ARG L-KEY WS-NO-STRICT LS-SUB
             IF LS-SUB NOT = 0
                 MOVE 1 TO L-STATUS
             END-IF
         WHEN "R"
             EVALUATE TRUE
                 WHEN JN-TYPE(L-NODE) = JT-STRING
                     CALL "SHAPE-VALUE" USING JSON-DOC L-NODE WS-D L-ARG L-NAME L-KEY L-STATUS
                 WHEN JN-TYPE(L-NODE) = JT-OBJECT
                     CALL "SHAPE-VALUE" USING JSON-DOC L-NODE WS-T L-ARG L-NAME L-KEY L-STATUS
                 WHEN OTHER
                     STRING "member " FUNCTION TRIM(L-NAME) " must be an identifier or an object"
                         DELIMITED BY SIZE INTO LS-DETAIL
             END-EVALUATE
         WHEN "V"
             EVALUATE TRUE
                 WHEN JN-TYPE(L-NODE) = JT-NUMBER
                     CONTINUE
                 WHEN JN-TYPE(L-NODE) = JT-OBJECT
                     CALL "SHAPE-VALUE" USING JSON-DOC L-NODE WS-T L-ARG L-NAME L-KEY L-STATUS
                 WHEN OTHER
                     STRING "member " FUNCTION TRIM(L-NAME) " must be a number or an object"
                         DELIMITED BY SIZE INTO LS-DETAIL
             END-EVALUATE
         WHEN "L"
             IF JN-TYPE(L-NODE) = JT-ARRAY
                 MOVE JN-FIRST(L-NODE) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     CALL "SHAPE-VALUE" USING JSON-DOC LS-CHILD WS-T L-ARG L-NAME L-KEY L-STATUS
                     MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                 END-PERFORM
             ELSE
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an array" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "K"
             IF JN-TYPE(L-NODE) = JT-ARRAY
                 MOVE JN-FIRST(L-NODE) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     CALL "SHAPE-VALUE" USING JSON-DOC LS-CHILD WS-D L-ARG L-NAME L-KEY L-STATUS
                     MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                 END-PERFORM
             ELSE
                 STRING "member " FUNCTION TRIM(L-NAME) " must be an array" DELIMITED BY SIZE INTO LS-DETAIL
             END-IF
         WHEN "H"
             EVALUATE TRUE
                 WHEN JN-TYPE(L-NODE) = JT-STRING
                     MOVE 0 TO LS-OK
                     CALL "JSON-STRING" USING JSON-DOC L-NODE LS-TEXT WS-CAPACITY LS-LENGTH
                     CALL "SHAPE-ID" USING LS-TEXT WS-ONE LS-OK
                     IF LS-OK = 0
                         STRING "member " FUNCTION TRIM(L-NAME) " must be an identifier or a tag"
                             DELIMITED BY SIZE INTO LS-DETAIL
                     END-IF
                 WHEN JN-TYPE(L-NODE) = JT-OBJECT
                     CALL "SHAPE-VALUE" USING JSON-DOC L-NODE WS-T L-ARG L-NAME L-KEY L-STATUS
                 WHEN JN-TYPE(L-NODE) = JT-ARRAY
                     MOVE JN-FIRST(L-NODE) TO LS-CHILD
                     PERFORM UNTIL LS-CHILD = 0
                         CALL "SHAPE-VALUE" USING JSON-DOC LS-CHILD WS-R L-ARG L-NAME L-KEY L-STATUS
                         MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                     END-PERFORM
                 WHEN OTHER
                     STRING "member " FUNCTION TRIM(L-NAME) " must be an identifier, a tag, an object or an array"
                         DELIMITED BY SIZE INTO LS-DETAIL
             END-EVALUATE
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     IF LS-DETAIL NOT = SPACES
         CALL "WG-FAIL" USING L-KEY LS-DETAIL
         MOVE 1 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM SHAPE-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-VALIDATE IS RECURSIVE.
*> USING JSON-DOC, node, group (PIC X(24)), key (PIC X(64), the element id), strict (BINARY-LONG), status out (BINARY-LONG:
*> 0, or 1 after an error was reported): checks an object against the shape of its type in the group: the "-" row of the
*> group when it has one, else the row its "type" member names. Every member of the field list is checked by SHAPE-VALUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-DASH                PIC X(48) VALUE "-".
 LOCAL-STORAGE SECTION.
 01 LS-ROW                 BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-NAME                PIC X(32).
 01 LS-TEXT                PIC X(200).
 01 LS-TYPE                PIC X(48).
 01 LS-SPEC                PIC X(600).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-POS                 BINARY-LONG.
 01 LS-TOKEN               PIC X(120).
 01 LS-FIELD               PIC X(32).
 01 LS-ARG                 PIC X(40).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-LETTER              PIC X.
 01 LS-UP                  PIC X.
 01 LS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-GROUP                PIC X(24).
 01 L-KEY                  PIC X(64).
 01 L-STRICT               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-GROUP L-KEY L-STRICT L-STATUS.
     MOVE 0 TO L-STATUS LS-ROW LS-LENGTH
     MOVE SPACES TO LS-DETAIL LS-SPEC
     IF JN-TYPE(L-NODE) NOT = JT-OBJECT
         STRING FUNCTION TRIM(L-GROUP) ": the value must be an object" DELIMITED BY SIZE INTO LS-DETAIL
     ELSE
         CALL "SHAPE-TYPE-FIND" USING L-GROUP WS-DASH LS-ROW
         IF LS-ROW = 0
             MOVE "type" TO LS-NAME
             CALL "RECIPE-GET-TEXT" USING JSON-DOC L-NODE LS-NAME LS-TEXT LS-FOUND
             IF LS-FOUND = 0
                 STRING FUNCTION TRIM(L-GROUP) ": the member type is missing or not a string"
                     DELIMITED BY SIZE INTO LS-DETAIL
             ELSE
                 MOVE LS-TEXT TO LS-TYPE
                 IF LS-TEXT(1:10) = "minecraft:"
                     MOVE SPACES TO LS-TYPE
                     MOVE LS-TEXT(11:) TO LS-TYPE
                 END-IF
                 CALL "SHAPE-TYPE-FIND" USING L-GROUP LS-TYPE LS-ROW
                 IF LS-ROW = 0 AND L-STRICT = 1
                     STRING FUNCTION TRIM(L-GROUP) ": unknown type " FUNCTION TRIM(LS-TYPE)
                         DELIMITED BY SIZE INTO LS-DETAIL
                 END-IF
             END-IF
         END-IF
     END-IF
     IF LS-DETAIL NOT = SPACES
         CALL "WG-FAIL" USING L-KEY LS-DETAIL
         MOVE 1 TO L-STATUS
     END-IF
     IF LS-ROW > 0
         MOVE SH-T-FIELDS(LS-ROW) TO LS-SPEC
         COMPUTE LS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(LS-SPEC TRAILING))
         MOVE 1 TO LS-POS
         PERFORM UNTIL LS-POS > LS-LENGTH
             MOVE SPACES TO LS-TOKEN LS-FIELD LS-ARG
             UNSTRING LS-SPEC DELIMITED BY ";" INTO LS-TOKEN WITH POINTER LS-POS
             MOVE LS-TOKEN(1:1) TO LS-LETTER
             MOVE FUNCTION UPPER-CASE(LS-LETTER) TO LS-UP
             UNSTRING LS-TOKEN(3:118) DELIMITED BY "=" INTO LS-FIELD LS-ARG
             CALL "RECIPE-MEMBER" USING JSON-DOC L-NODE LS-FIELD LS-MEMBER
             EVALUATE TRUE
                 WHEN LS-MEMBER > 0
                     CALL "SHAPE-VALUE" USING JSON-DOC LS-MEMBER LS-UP LS-ARG LS-FIELD L-KEY L-STATUS
                 WHEN LS-LETTER = LS-UP
                     MOVE SPACES TO LS-DETAIL
                     STRING FUNCTION TRIM(L-GROUP) ": the member " FUNCTION TRIM(LS-FIELD) " is missing"
                         DELIMITED BY SIZE INTO LS-DETAIL
                     CALL "WG-FAIL" USING L-KEY LS-DETAIL
                     MOVE 1 TO L-STATUS
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SHAPE-VALIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-BEGIN.
*> No parameters: starts a load. The elements now stored are kept by SHAPE-END whatever happens, and the error count is
*> cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 COPY CTLOAD.
 PROCEDURE DIVISION.
     MOVE SH-ELEMENT-COUNT TO SH-MARK
     MOVE 0 TO RS-ERRORS
     GOBACK.
 END PROGRAM SHAPE-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-END.
*> USING status out (CT-OK, or CT-BAD-DATA when an error was reported since SHAPE-BEGIN; then the elements loaded since
*> are freed and gone).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSHAPE.
 COPY CTLOAD.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS.
     MOVE CT-OK TO L-STATUS
     IF RS-ERRORS > 0
         MOVE CT-BAD-DATA TO L-STATUS
         PERFORM VARYING WS-I FROM SH-ELEMENT-COUNT BY -1 UNTIL WS-I <= SH-MARK
             FREE SH-E-ADDR(WS-I)
         END-PERFORM
         MOVE SH-MARK TO SH-ELEMENT-COUNT
     END-IF
     GOBACK.
 END PROGRAM SHAPE-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-FIND.
*> USING registry (PIC X(48)), key (PIC X(64), "namespace:path"), row out (BINARY-LONG: the element row, 0 when there is
*> none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SH-ELEMENT-COUNT OR L-ROW > 0
         IF SH-E-REGISTRY(WS-I) = L-REGISTRY AND SH-E-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHAPE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-FILE-ADD.
*> USING JSON-DOC, registry (PIC X(48)), group (PIC X(24)), key (PIC X(64)), text address (POINTER), length (BINARY-LONG),
*> strict (BINARY-LONG): checks one file the strict reader accepted and stores it as an element when it passes; errors
*> are reported and counted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 B-COPY                 PIC X(268435456) BASED.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-TEXT                PIC X(200).
 01 WS-TYPE                PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 01 WS-DASH                PIC X(48) VALUE "-".
 01 WS-COPY                USAGE POINTER.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-REGISTRY             PIC X(48).
 01 L-GROUP                PIC X(24).
 01 L-KEY                  PIC X(64).
 01 L-ADDR                 USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 01 L-STRICT               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-REGISTRY L-GROUP L-KEY L-ADDR L-LENGTH L-STRICT.
     SET ADDRESS OF B-TEXT TO L-ADDR
     CALL "JSON-PARSE" USING JSON-DOC B-TEXT L-LENGTH
     CALL "SHAPE-VALIDATE" USING JSON-DOC WS-ONE L-GROUP L-KEY L-STRICT WS-STATUS
     IF WS-STATUS = 0
         IF SH-ELEMENT-COUNT >= SH-MAX-ELEMENTS
             MOVE "the shape element table is full" TO WS-DETAIL
             CALL "WG-FAIL" USING L-KEY WS-DETAIL
         ELSE
             ADD 1 TO SH-ELEMENT-COUNT
             ALLOCATE L-LENGTH CHARACTERS RETURNING WS-COPY
             SET ADDRESS OF B-COPY TO WS-COPY
             MOVE B-TEXT(1:L-LENGTH) TO B-COPY(1:L-LENGTH)
             SET SH-E-ADDR(SH-ELEMENT-COUNT) TO WS-COPY
             MOVE L-LENGTH TO SH-E-LENGTH(SH-ELEMENT-COUNT)
             MOVE L-REGISTRY TO SH-E-REGISTRY(SH-ELEMENT-COUNT)
             MOVE L-KEY TO SH-E-KEY(SH-ELEMENT-COUNT)
             MOVE 0 TO SH-E-TYPE(SH-ELEMENT-COUNT)
             CALL "SHAPE-TYPE-FIND" USING L-GROUP WS-DASH WS-ROW
             IF WS-ROW = 0
                 MOVE "type" TO WS-NAME
                 CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ONE WS-NAME WS-TEXT WS-FOUND
                 MOVE WS-TEXT TO WS-TYPE
                 IF WS-TEXT(1:10) = "minecraft:"
                     MOVE SPACES TO WS-TYPE
                     MOVE WS-TEXT(11:) TO WS-TYPE
                 END-IF
                 CALL "SHAPE-TYPE-FIND" USING L-GROUP WS-TYPE WS-ROW
             END-IF
             MOVE WS-ROW TO SH-E-TYPE(SH-ELEMENT-COUNT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHAPE-FILE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHAPE-LOAD.
*> USING root (PIC X(1100): the folder that holds data/), registry (PIC X(48), "worldgen/placed_feature"), group (PIC X(24)),
*> strict (BINARY-LONG): reads the files of data/<namespace>/<registry>/**/*.json of the folder (the registry loader of
*> registry.cob) and adds each through SHAPE-FILE-ADD. Errors are counted for SHAPE-END; the registries of an open
*> content set are not touched (the registry loader's table is a private one).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY CTLOAD.
 COPY CTWORLDGEN.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-DIR-Z               PIC X(1101).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-BASE                PIC X(1101).
 01 WS-MESSAGE             PIC X(200).
 01 WS-TABLE               USAGE POINTER.
 01 WS-SAVED-ADDR          USAGE POINTER.
 01 WS-SAVED-COUNT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-PAYLOAD             USAGE POINTER.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-REGISTRY             PIC X(48).
 01 L-GROUP                PIC X(24).
 01 L-STRICT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-REGISTRY L-GROUP L-STRICT.
     CALL "FILE-PATH-Z" USING L-DIR WS-DIR-Z WS-DIR-LENGTH WS-PATH-STATUS
     IF WS-PATH-STATUS NOT = FM-OK
         MOVE "the data directory path is too long" TO WS-MESSAGE
         CALL "RS-ERROR" USING WS-MESSAGE
     ELSE
         MOVE SPACES TO WG-LABEL
         MOVE L-REGISTRY TO WG-LABEL
         MOVE LOW-VALUES TO WS-BASE
         STRING WS-DIR-Z(1:WS-DIR-LENGTH) "/data" DELIMITED BY SIZE INTO WS-BASE
         SET WS-SAVED-ADDR TO CT-REGISTRY-ADDR
         MOVE CT-REGISTRY-COUNT TO WS-SAVED-COUNT
         ALLOCATE LENGTH OF B-REGISTRIES CHARACTERS RETURNING WS-TABLE
         SET CT-REGISTRY-ADDR TO WS-TABLE
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         MOVE SPACES TO BR-KEY(1)
         MOVE 0 TO BR-KEY-LENGTH(1) BR-ENTRY-COUNT(1) BR-PAYLOAD-LENGTH(1)
         SET BR-ENTRY-ADDR(1) TO NULL
         SET BR-PAYLOAD-ADDR(1) TO NULL
         MOVE 1 TO CT-REGISTRY-COUNT WS-SLOT
         MOVE 0 TO RS-MODE
         CALL "REGISTRY-LOAD-ONE" USING WS-BASE L-REGISTRY WS-SLOT
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-ENTRY-COUNT(1)
             SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(1)
             MOVE BE-KEY(WS-I) TO WS-KEY
             MOVE BE-PAYLOAD-LENGTH(WS-I) TO WS-LENGTH
             SET WS-PAYLOAD TO BR-PAYLOAD-ADDR(1)
             SET WS-PAYLOAD UP BY BE-PAYLOAD-OFFSET(WS-I)
             CALL "SHAPE-FILE-ADD" USING JSON-DOC L-REGISTRY L-GROUP WS-KEY WS-PAYLOAD WS-LENGTH L-STRICT
         END-PERFORM
         CALL "REGISTRY-FREE"
         SET CT-REGISTRY-ADDR TO WS-SAVED-ADDR
         MOVE WS-SAVED-COUNT TO CT-REGISTRY-COUNT
     END-IF
     GOBACK.
 END PROGRAM SHAPE-LOAD.
