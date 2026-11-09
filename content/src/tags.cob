*> Tag loading and resolution of the content library (content-api section 2; docs/protocol/23-registry-loading.md section 6, and
*> 6.6 for the network form). TAG-ADD-FILE collects the tag files of every pack in pack order (lowest
*> priority first, 6.2), TAGS-BUILD resolves the collected tags of one registry (6.3 steps B to D: a tag
*> is built after the tags it requires, an edge that would close a cycle is dropped, required edges
*> before optional ones; members are the element ids in first-occurrence order, nested tags inserted at
*> their place, 6.4) and binds them to the set as CT-TAG rows (CTSTORE.cpy: key, registry, member ids).
*> A tag with a missing required reference is not built and prints "Couldn't load tag <tag> as it is
*> missing following references: ..."; for a registry loaded from data a required element that no file
*> defines is a freeze error instead (the tag is built without it and TAGS-BUILD answers CT-BAD-DATA).
*> The same CONTENT-TAG-HAS and CONTENT-TAG-MEMBERS serve every set, including the client's network tags
*> (TAG-PUT binds a resolved tag, 6.6). Static registry elements are looked up through the set's tables
*> (CONTENT-STATIC-ID), loaded registry elements in the entries of the registry.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-BEGIN.
*> No parameters: forgets the collected tag files (the bound tags of the set stay).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTTAGS.
 PROCEDURE DIVISION.
     MOVE 0 TO TG-TAG-COUNT TG-ENTRY-COUNT TG-ERRORS
     GOBACK.
 END PROGRAM TAGS-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-NORMALIZE.
*> USING registry (PIC X(48), in and out), tag key (PIC X(64), in and out): the registry without "minecraft:",
*> the tag key with a namespace ("minecraft:" when it has none). A key that holds no ":" is the path.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLONS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 PROCEDURE DIVISION USING L-REGISTRY L-KEY.
     IF L-REGISTRY(1:10) = "minecraft:"
         MOVE SPACES TO WS-REGISTRY
         MOVE L-REGISTRY(11:38) TO WS-REGISTRY
         MOVE WS-REGISTRY TO L-REGISTRY
     END-IF
     MOVE 0 TO WS-COLONS
     INSPECT L-KEY TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-KEY
         MOVE WS-KEY TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM TAG-NORMALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-ID-PARSE.
*> USING text (PIC X(128)), length (BINARY-LONG), kind out (PIC X: E an element, T a tag after a leading "#"),
*> id out (PIC X(64): namespace ":" path, "minecraft" when the text has no namespace), ok out (BINARY-LONG 1 or
*> 0). 23 section 1: split at the first ":" (a ":" at index 0 gives "minecraft"); namespace of a-z 0-9 _ - .
*> (not ".."), path of those and "/"; "##a:b", "a:#b" and "#" alone fail; the id is at most 64 bytes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-NS                  PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(128).
 01 L-LENGTH               BINARY-LONG.
 01 L-KIND                 PIC X.
 01 L-ID                   PIC X(64).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-KIND L-ID L-OK.
     MOVE 0 TO L-OK
     MOVE "E" TO L-KIND
     MOVE SPACES TO L-ID
     IF L-LENGTH < 1 OR L-LENGTH > 128
         GOBACK
     END-IF
     MOVE 1 TO WS-START
     IF L-TEXT(1:1) = "#"
         MOVE "T" TO L-KIND
         MOVE 2 TO WS-START
     END-IF
     COMPUTE WS-REST = L-LENGTH - WS-START + 1
     IF WS-REST < 1
         GOBACK
     END-IF
     MOVE 0 TO WS-COLON
     INSPECT L-TEXT(WS-START:WS-REST) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
     MOVE SPACES TO WS-NS WS-PATH
     EVALUATE TRUE
         WHEN WS-COLON >= WS-REST
             MOVE "minecraft" TO WS-NS
             MOVE 9 TO WS-NS-LENGTH
             MOVE WS-REST TO WS-PATH-LENGTH
             IF WS-REST > 64
                 GOBACK
             END-IF
             MOVE L-TEXT(WS-START:WS-REST) TO WS-PATH
         WHEN OTHER
             IF WS-COLON = 0
                 MOVE "minecraft" TO WS-NS
                 MOVE 9 TO WS-NS-LENGTH
             ELSE
                 IF WS-COLON > 63
                     GOBACK
                 END-IF
                 MOVE L-TEXT(WS-START:WS-COLON) TO WS-NS
                 MOVE WS-COLON TO WS-NS-LENGTH
             END-IF
             COMPUTE WS-PATH-LENGTH = WS-REST - WS-COLON - 1
             IF WS-PATH-LENGTH > 64
                 GOBACK
             END-IF
             IF WS-PATH-LENGTH > 0
                 MOVE L-TEXT(WS-START + WS-COLON + 1:WS-PATH-LENGTH) TO WS-PATH
             END-IF
     END-EVALUATE
     MOVE 1 TO WS-MODE
     CALL "RS-ID-VALID" USING WS-NS WS-NS-LENGTH WS-MODE
     IF WS-MODE = 0
         GOBACK
     END-IF
     MOVE 2 TO WS-MODE
     CALL "RS-ID-VALID" USING WS-PATH WS-PATH-LENGTH WS-MODE
     IF WS-MODE = 0 OR WS-NS-LENGTH + 1 + WS-PATH-LENGTH > 64
         GOBACK
     END-IF
     STRING WS-NS(1:WS-NS-LENGTH) ":" WS-PATH(1:WS-PATH-LENGTH) DELIMITED BY SIZE INTO L-ID
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM TAG-ID-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-IGNORE.
*> USING tag key (PIC X(64)), pack name (PIC X(32)), reason (PIC X(200)): prints the line of 23 6.3 step A on
*> standard error for a tag file that is ignored.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  PIC X(64).
 01 L-PACK                 PIC X(32).
 01 L-MESSAGE              PIC X(200).
 PROCEDURE DIVISION USING L-TAG L-PACK L-MESSAGE.
     DISPLAY "ERROR tags: Couldn't read tag list " FUNCTION TRIM(L-TAG) " in data pack "
         FUNCTION TRIM(L-PACK) " (" FUNCTION TRIM(L-MESSAGE) ")" UPON SYSERR
     GOBACK.
 END PROGRAM TAG-IGNORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-ADD-FILE.
*> USING registry (PIC X(48)), tag key (PIC X(64)), pack name (PIC X(32)), text area (any size), length
*> (BINARY-LONG), status out (CT-OK; CT-BAD-DATA when the file is ignored, with a line "ERROR tags: Couldn't
*> read tag list ..." on standard error). Collects one pack's file of a tag (23 6.3 step A): the strict
*> reader first (a failure leaves no trace); then the tag exists; then the file decodes (an object with
*> "values", an array of strings or {id, required} objects, and an optional boolean "replace") or is ignored
*> whole; "replace" discards the entries collected so far for this tag; the entries are appended.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTTAGS.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-KEY-VALUES          PIC X(6) VALUE "values".
 01 WS-KEY-REPLACE         PIC X(7) VALUE "replace".
 01 WS-KEY-ID              PIC X(2) VALUE "id".
 01 WS-KEY-REQUIRED        PIC X(8) VALUE "required".
 01 WS-LENGTHS.
    05 WS-LEN-VALUES       BINARY-LONG VALUE 6.
    05 WS-LEN-REPLACE      BINARY-LONG VALUE 7.
    05 WS-LEN-ID           BINARY-LONG VALUE 2.
    05 WS-LEN-REQUIRED     BINARY-LONG VALUE 8.
    05 WS-LEN-TEXT         BINARY-LONG VALUE 128.
 01 WS-REGISTRY            PIC X(48).
 01 WS-TAG                 PIC X(64).
 01 WS-OFFSET              BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-VALUES              BINARY-LONG.
 01 WS-REPLACE-NODE        BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TEXT                PIC X(128).
 01 WS-TAG-INDEX           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-KIND                PIC X.
 01 WS-ID                  PIC X(64).
 01 WS-OK                  BINARY-LONG.
 01 WS-REQUIRED            PIC X.
 01 WS-MESSAGE             PIC X(200).
 01 WS-PENDING.
    05 WS-P-ENTRY OCCURS 4096 TIMES.
       10 WS-P-KIND        PIC X.
       10 WS-P-REQUIRED    PIC X.
       10 WS-P-ID          PIC X(64).
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(64).
 01 L-PACK                 PIC X(32).
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-PACK L-TEXT L-LENGTH L-STATUS.
     MOVE CT-BAD-DATA TO L-STATUS
     MOVE L-REGISTRY TO WS-REGISTRY
     MOVE L-TAG TO WS-TAG
     CALL "TAG-NORMALIZE" USING WS-REGISTRY WS-TAG
     CALL "JSON-STRICT" USING L-TEXT L-LENGTH JSON-DOC WS-OFFSET WS-REASON
     IF WS-REASON NOT = FM-JS-OK
         MOVE "syntax error" TO WS-MESSAGE
         CALL "TAG-IGNORE" USING WS-TAG L-PACK WS-MESSAGE
         GOBACK
     END-IF
*>   The tag exists from here on.
     MOVE 0 TO WS-TAG-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-TAG-COUNT OR WS-TAG-INDEX > 0
         IF TG-T-REGISTRY(WS-I) = WS-REGISTRY AND TG-T-KEY(WS-I) = WS-TAG
             MOVE WS-I TO WS-TAG-INDEX
         END-IF
     END-PERFORM
     IF WS-TAG-INDEX = 0
         IF TG-TAG-COUNT >= TG-MAX-TAGS
             MOVE "too many tags" TO WS-MESSAGE
             CALL "TAG-IGNORE" USING WS-TAG L-PACK WS-MESSAGE
             GOBACK
         END-IF
         ADD 1 TO TG-TAG-COUNT
         MOVE TG-TAG-COUNT TO WS-TAG-INDEX
         MOVE WS-TAG TO TG-T-KEY(WS-TAG-INDEX)
         MOVE WS-REGISTRY TO TG-T-REGISTRY(WS-TAG-INDEX)
         MOVE 0 TO TG-T-STATE(WS-TAG-INDEX) TG-T-MARK(WS-TAG-INDEX)
     END-IF
*>   Decode: "values" an array, "replace" a boolean when present.
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY-VALUES WS-LEN-VALUES WS-VALUES
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY-REPLACE WS-LEN-REPLACE WS-REPLACE-NODE
     MOVE 0 TO WS-REPLACE WS-BAD
     IF WS-VALUES = 0
         MOVE 1 TO WS-BAD
     ELSE
         IF JN-TYPE(WS-VALUES) NOT = JT-ARRAY
             MOVE 1 TO WS-BAD
         END-IF
     END-IF
     IF WS-REPLACE-NODE > 0
         EVALUATE JN-TYPE(WS-REPLACE-NODE)
             WHEN JT-TRUE
                 MOVE 1 TO WS-REPLACE
             WHEN JT-FALSE
                 MOVE 0 TO WS-REPLACE
             WHEN OTHER
                 MOVE 1 TO WS-BAD
         END-EVALUATE
     END-IF
     MOVE 0 TO WS-N
     IF WS-BAD = 0
         MOVE JN-FIRST(WS-VALUES) TO WS-NODE
         PERFORM UNTIL WS-NODE = 0 OR WS-BAD = 1
        *>   A string is a required element or tag; an object has "id" (a string) and an optional boolean "required".
             MOVE "Y" TO WS-REQUIRED
             MOVE WS-NODE TO WS-MEMBER
             EVALUATE JN-TYPE(WS-NODE)
                 WHEN JT-STRING
                     CONTINUE
                 WHEN JT-OBJECT
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY-ID WS-LEN-ID WS-MEMBER
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY-REQUIRED WS-LEN-REQUIRED WS-REPLACE-NODE
                     IF WS-MEMBER = 0
                         MOVE 1 TO WS-BAD
                     ELSE
                         IF JN-TYPE(WS-MEMBER) NOT = JT-STRING
                             MOVE 1 TO WS-BAD
                         END-IF
                     END-IF
                     IF WS-REPLACE-NODE > 0
                         EVALUATE JN-TYPE(WS-REPLACE-NODE)
                             WHEN JT-TRUE
                                 CONTINUE
                             WHEN JT-FALSE
                                 MOVE "N" TO WS-REQUIRED
                             WHEN OTHER
                                 MOVE 1 TO WS-BAD
                         END-EVALUATE
                     END-IF
                 WHEN OTHER
                     MOVE 1 TO WS-BAD
             END-EVALUATE
             IF WS-BAD = 0
                 MOVE SPACES TO WS-TEXT
                 CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-TEXT WS-LEN-TEXT WS-LEN
                 CALL "TAG-ID-PARSE" USING WS-TEXT WS-LEN WS-KIND WS-ID WS-OK
                 IF WS-OK = 0 OR WS-N >= 4096
                     MOVE 1 TO WS-BAD
                 ELSE
                     ADD 1 TO WS-N
                     MOVE WS-KIND TO WS-P-KIND(WS-N)
                     MOVE WS-REQUIRED TO WS-P-REQUIRED(WS-N)
                     MOVE WS-ID TO WS-P-ID(WS-N)
                 END-IF
             END-IF
             MOVE JN-NEXT(WS-NODE) TO WS-NODE
         END-PERFORM
     END-IF
     IF WS-BAD = 1
         MOVE "does not decode" TO WS-MESSAGE
         CALL "TAG-IGNORE" USING WS-TAG L-PACK WS-MESSAGE
         GOBACK
     END-IF
     IF TG-ENTRY-COUNT + WS-N > TG-MAX-ENTRIES
         MOVE "too many tag entries" TO WS-MESSAGE
         CALL "TAG-IGNORE" USING WS-TAG L-PACK WS-MESSAGE
         GOBACK
     END-IF
     IF WS-REPLACE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-ENTRY-COUNT
             IF TG-E-TAG(WS-I) = WS-TAG-INDEX
                 MOVE "N" TO TG-E-ALIVE(WS-I)
             END-IF
         END-PERFORM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         ADD 1 TO TG-ENTRY-COUNT
         MOVE WS-TAG-INDEX TO TG-E-TAG(TG-ENTRY-COUNT)
         MOVE WS-P-KIND(WS-I) TO TG-E-KIND(TG-ENTRY-COUNT)
         MOVE WS-P-REQUIRED(WS-I) TO TG-E-REQUIRED(TG-ENTRY-COUNT)
         MOVE "Y" TO TG-E-ALIVE(TG-ENTRY-COUNT)
         MOVE WS-P-ID(WS-I) TO TG-E-ID(TG-ENTRY-COUNT)
         MOVE L-PACK TO TG-E-PACK(TG-ENTRY-COUNT)
     END-PERFORM
     MOVE CT-OK TO L-STATUS
     GOBACK.



 END PROGRAM TAG-ADD-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-BUILD.
*> USING registry (PIC X(48)), status out (CT-OK, or CT-BAD-DATA when a freeze error or a full tag table was
*> found): builds every collected tag of the registry that is not built yet and binds the built ones.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTTAGS.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-STATUS.
     MOVE L-REGISTRY TO WS-REGISTRY
     MOVE "x" TO WS-KEY
     CALL "TAG-NORMALIZE" USING WS-REGISTRY WS-KEY
     MOVE 0 TO TG-ERRORS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-TAG-COUNT
         IF TG-T-REGISTRY(WS-I) = WS-REGISTRY AND TG-T-STATE(WS-I) = 0
             CALL "TAG-BUILD-ONE" USING WS-I
         END-IF
     END-PERFORM
     IF TG-ERRORS > 0
         MOVE CT-BAD-DATA TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM TAGS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-ADD-MEMBER.
*> USING members (a table of 4096 BINARY-LONG), count (BINARY-LONG, in and out), id (BINARY-LONG): appends the id
*> unless it is already there (order of first occurrence, 23 6.4) or the table is full.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MEMBERS.
    05 L-MEMBER            BINARY-LONG OCCURS 4096 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MEMBERS L-COUNT L-ID.
     MOVE 0 TO WS-HAVE
     PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > L-COUNT OR WS-HAVE = 1
         IF L-MEMBER(WS-M) = L-ID
             MOVE 1 TO WS-HAVE
         END-IF
     END-PERFORM
     IF WS-HAVE = 0 AND L-COUNT < 4096
         ADD 1 TO L-COUNT
         MOVE L-ID TO L-MEMBER(L-COUNT)
     END-IF
     GOBACK.
 END PROGRAM TAG-ADD-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-NOTE-FAILURE.
*> USING list (PIC X(300), the text so far), position (BINARY-LONG, the next byte of the list), kind (PIC X: T a
*> tag reference, E an element), entry id (PIC X(64)), pack (PIC X(32)): appends "<entry> (from <pack>)" to
*> the list of references a tag is missing, ", " apart (6.3 step C).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHOWN               PIC X(66).
 LINKAGE SECTION.
 01 L-LIST                 PIC X(300).
 01 L-POS                  BINARY-LONG.
 01 L-KIND                 PIC X.
 01 L-ID                   PIC X(64).
 01 L-PACK                 PIC X(32).
 PROCEDURE DIVISION USING L-LIST L-POS L-KIND L-ID L-PACK.
     MOVE SPACES TO WS-SHOWN
     IF L-KIND = "T"
         STRING "#" FUNCTION TRIM(L-ID) DELIMITED BY SIZE INTO WS-SHOWN
     ELSE
         MOVE L-ID TO WS-SHOWN
     END-IF
     IF L-POS > 1
         STRING ", " DELIMITED BY SIZE INTO L-LIST WITH POINTER L-POS
     END-IF
     STRING FUNCTION TRIM(WS-SHOWN) " (from " FUNCTION TRIM(L-PACK) ")" DELIMITED BY SIZE
         INTO L-LIST WITH POINTER L-POS
     GOBACK.
 END PROGRAM TAG-NOTE-FAILURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-BUILD-ONE IS RECURSIVE.
*> USING tag index (BINARY-LONG): builds one collected tag (23 6.3 step C): its required tags first, an optional
*> tag only when it cannot reach this tag through required references; the members are entered in entry
*> order without duplicates; the built tag is bound with TAG-PUT. State 3 (failed) tags are not bound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTTAGS.
 LOCAL-STORAGE SECTION.
 01 LS-MEMBERS.
    05 LS-MEMBER           BINARY-LONG OCCURS 4096 TIMES.
 01 LS-DEPENDENCY.
    05 LS-DEP              BINARY-LONG OCCURS 4096 TIMES.
 01 LS-COUNT               BINARY-LONG.
 01 LS-DEP-COUNT           BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-FAIL                BINARY-LONG.
 01 LS-MISS                BINARY-LONG.
 01 LS-ID                  BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-STATUS              BINARY-LONG.
 01 LS-REACHES             BINARY-LONG.
 01 LS-REGISTRY            PIC X(48).
 01 LS-KEY                 PIC X(64).
 01 LS-LIST                PIC X(300).
 01 LS-POS                 BINARY-LONG.
 01 LS-REQUIRED            PIC X.
 01 LS-WHAT                PIC X(64).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE 1 TO TG-T-STATE(L-INDEX)
     MOVE TG-T-REGISTRY(L-INDEX) TO LS-REGISTRY
     MOVE 0 TO LS-COUNT LS-FAIL
     MOVE SPACES TO LS-LIST
     MOVE 1 TO LS-POS
     PERFORM VARYING LS-E FROM 1 BY 1 UNTIL LS-E > TG-ENTRY-COUNT
         IF TG-E-TAG(LS-E) = L-INDEX AND TG-E-ALIVE(LS-E) = "Y"
             MOVE TG-E-REQUIRED(LS-E) TO LS-REQUIRED
             IF TG-E-KIND(LS-E) = "E"
*>               An element: found in the registry, else a required one fails the tag (static registry) or is a
*>               freeze error (a registry loaded from data creates the holder at once, 23 6.3).
                 MOVE TG-E-ID(LS-E) TO LS-WHAT
                 CALL "TAG-ELEMENT-ID" USING LS-REGISTRY LS-WHAT LS-ID LS-FOUND LS-KIND
                 EVALUATE TRUE
                     WHEN LS-FOUND = 1
                         CALL "TAG-ADD-MEMBER" USING LS-MEMBERS LS-COUNT LS-ID
                     WHEN LS-REQUIRED = "Y" AND LS-KIND = 1
                         ADD 1 TO TG-ERRORS
                         DISPLAY "ERROR tags: Unbound values in registry minecraft:" FUNCTION TRIM(LS-REGISTRY)
                             ": " FUNCTION TRIM(LS-WHAT) UPON SYSERR
                     WHEN LS-REQUIRED = "Y"
                         MOVE 1 TO LS-FAIL
                         CALL "TAG-NOTE-FAILURE" USING LS-LIST LS-POS TG-E-KIND(LS-E) TG-E-ID(LS-E)
                             TG-E-PACK(LS-E)
                 END-EVALUATE
             ELSE
*>               A tag reference: find the tag among the collected tags of this registry, build it first when
*>               it is not built (an optional one not when it reaches this tag), then take its members.
                 MOVE 0 TO LS-J
                 PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > TG-TAG-COUNT OR LS-J > 0
                     IF TG-T-REGISTRY(LS-K) = LS-REGISTRY AND TG-T-KEY(LS-K) = TG-E-ID(LS-E)
                         MOVE LS-K TO LS-J
                     END-IF
                 END-PERFORM
                 IF LS-J > 0
                     IF TG-T-STATE(LS-J) = 0
                         MOVE 0 TO LS-REACHES
                         IF LS-REQUIRED = "N"
                             CALL "TAG-REACHES" USING LS-J L-INDEX LS-REACHES
                         END-IF
                         IF LS-REACHES = 0
                             CALL "TAG-BUILD-ONE" USING LS-J
                         END-IF
                     END-IF
                 END-IF
                 MOVE 0 TO LS-DEP-COUNT
                 IF LS-J > 0
                     IF TG-T-STATE(LS-J) = 2
                         MOVE TG-T-KEY(LS-J) TO LS-KEY
                         MOVE 4096 TO LS-CAPACITY
                         CALL "CONTENT-TAG-MEMBERS" USING LS-REGISTRY LS-KEY LS-DEP-COUNT LS-DEPENDENCY
                             LS-CAPACITY LS-STATUS
                         PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > LS-DEP-COUNT
                             MOVE LS-DEP(LS-K) TO LS-ID
                             CALL "TAG-ADD-MEMBER" USING LS-MEMBERS LS-COUNT LS-ID
                         END-PERFORM
                     END-IF
                 END-IF
                 IF LS-REQUIRED = "Y"
                     MOVE 0 TO LS-MISS
                     IF LS-J = 0
                         MOVE 1 TO LS-MISS
                     ELSE
                         IF TG-T-STATE(LS-J) NOT = 2
                             MOVE 1 TO LS-MISS
                         END-IF
                     END-IF
                     IF LS-MISS = 1
                         MOVE 1 TO LS-FAIL
                         CALL "TAG-NOTE-FAILURE" USING LS-LIST LS-POS TG-E-KIND(LS-E) TG-E-ID(LS-E)
                             TG-E-PACK(LS-E)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF LS-FAIL = 1
         MOVE 3 TO TG-T-STATE(L-INDEX)
         DISPLAY "ERROR tags: Couldn't load tag " FUNCTION TRIM(TG-T-KEY(L-INDEX))
             " as it is missing following references: " FUNCTION TRIM(LS-LIST) UPON SYSERR
     ELSE
         MOVE TG-T-KEY(L-INDEX) TO LS-KEY
         CALL "TAG-PUT" USING LS-REGISTRY LS-KEY LS-COUNT LS-MEMBERS LS-STATUS
         IF LS-STATUS = CT-OK
             MOVE 2 TO TG-T-STATE(L-INDEX)
         ELSE
             MOVE 3 TO TG-T-STATE(L-INDEX)
             ADD 1 TO TG-ERRORS
             DISPLAY "ERROR tags: the tag table is full at " FUNCTION TRIM(LS-KEY) UPON SYSERR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TAG-BUILD-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-REACHES.
*> USING from tag index, to tag index, result out (BINARY-LONG 1 when "from" reaches "to" through required tag
*> references of the collected entries, else 0): the test of the dependency sorter's edge check (23 6.3 B)
*> for an optional edge.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTTAGS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-RESULT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-TAG-COUNT
         MOVE 0 TO TG-T-MARK(WS-I)
     END-PERFORM
     CALL "TAG-REACH-STEP" USING L-FROM L-TO L-RESULT
     GOBACK.
 END PROGRAM TAG-REACHES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-REACH-STEP IS RECURSIVE.
*> USING from, to, result out: depth first over the required tag references, each tag visited once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTTAGS.
 LOCAL-STORAGE SECTION.
 01 LS-E                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-INNER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-FROM = L-TO
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     MOVE 1 TO TG-T-MARK(L-FROM)
     PERFORM VARYING LS-E FROM 1 BY 1 UNTIL LS-E > TG-ENTRY-COUNT OR L-RESULT = 1
         IF TG-E-TAG(LS-E) = L-FROM AND TG-E-ALIVE(LS-E) = "Y" AND TG-E-KIND(LS-E) = "T"
            AND TG-E-REQUIRED(LS-E) = "Y"
             MOVE 0 TO LS-J
             PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > TG-TAG-COUNT OR LS-J > 0
                 IF TG-T-REGISTRY(LS-K) = TG-T-REGISTRY(L-FROM) AND TG-T-KEY(LS-K) = TG-E-ID(LS-E)
                     MOVE LS-K TO LS-J
                 END-IF
             END-PERFORM
             IF LS-J > 0
                 IF TG-T-MARK(LS-J) = 0
                     CALL "TAG-REACH-STEP" USING LS-J L-TO LS-INNER
                     MOVE LS-INNER TO L-RESULT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TAG-REACH-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-ELEMENT-ID.
*> USING registry (PIC X(48)), element key (PIC X(64), namespace:path), id out (BINARY-LONG), found out (1 or 0),
*> kind out (1 the registry is loaded from data in this set, 2 a static registry): the id of an element in the
*> entries of a loaded registry (the order of 23 3.4) or in the set's static tables (CONTENT-STATIC-ID).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-FULL                PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(64).
 01 L-ID                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-ID L-FOUND L-KIND.
     MOVE 0 TO L-ID L-FOUND WS-ROW
     MOVE 2 TO L-KIND
     IF CT-REGISTRY-ADDR NOT = NULL
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         MOVE SPACES TO WS-FULL
         STRING "minecraft:" FUNCTION TRIM(L-REGISTRY) DELIMITED BY SIZE INTO WS-FULL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR WS-ROW > 0
             IF BR-KEY(WS-I) = WS-FULL
                 MOVE WS-I TO WS-ROW
             END-IF
         END-PERFORM
     END-IF
     IF WS-ROW > 0
         MOVE 1 TO L-KIND
         IF BR-ENTRY-COUNT(WS-ROW) > 0
             SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(WS-ROW)
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BR-ENTRY-COUNT(WS-ROW) OR L-FOUND = 1
                 IF BE-KEY(WS-J) = L-KEY
                     COMPUTE L-ID = WS-J - 1
                     MOVE 1 TO L-FOUND
                 END-IF
             END-PERFORM
         END-IF
     ELSE
         CALL "CONTENT-STATIC-ID" USING L-REGISTRY L-KEY L-ID WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TAG-ELEMENT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-FIND.
*> USING registry (PIC X(48)), tag key (PIC X(64)), row out (BINARY-LONG: the 1-based row of the bound tag, 0
*> when there is none). Both names are taken as given by a caller (namespaces optional).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(64).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-ROW.
     MOVE 0 TO L-ROW
     IF CT-TAG-ADDR = NULL
         GOBACK
     END-IF
     MOVE L-REGISTRY TO WS-REGISTRY
     MOVE L-TAG TO WS-KEY
     CALL "TAG-NORMALIZE" USING WS-REGISTRY WS-KEY
     SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-TAG-COUNT OR L-ROW > 0
         IF BT-REGISTRY(WS-I) = WS-REGISTRY AND BT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TAG-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAG-PUT.
*> USING registry (PIC X(48)), tag key (PIC X(64)), member count (BINARY-LONG), ids (a table of BINARY-LONG), status
*> out (CT-OK; CT-TOO-SMALL when the set's tag table of 4096 tags is full): binds one resolved tag to the set,
*> replacing a tag of the same registry and key (23 6.3 step D, 6.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 B-SOURCE-IDS           PIC X(4194304) BASED.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ADDR                USAGE POINTER.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(64).
 01 L-COUNT                BINARY-LONG.
 01 L-IDS                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-COUNT L-IDS L-STATUS.
     MOVE L-REGISTRY TO WS-REGISTRY
     MOVE L-TAG TO WS-KEY
     CALL "TAG-NORMALIZE" USING WS-REGISTRY WS-KEY
     IF CT-TAG-ADDR = NULL
         ALLOCATE LENGTH OF B-TAGS CHARACTERS RETURNING WS-ADDR
         SET CT-TAG-ADDR TO WS-ADDR
         MOVE 0 TO CT-TAG-COUNT
     END-IF
     SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
     CALL "TAG-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     IF WS-ROW > 0
         IF BT-MEMBER-ADDR(WS-ROW) NOT = NULL
             FREE BT-MEMBER-ADDR(WS-ROW)
         END-IF
     ELSE
         IF CT-TAG-COUNT >= 4096
             MOVE CT-TOO-SMALL TO L-STATUS
             GOBACK
         END-IF
         ADD 1 TO CT-TAG-COUNT
         MOVE CT-TAG-COUNT TO WS-ROW
     END-IF
     MOVE WS-KEY TO BT-KEY(WS-ROW)
     MOVE 0 TO BT-KEY-LENGTH(WS-ROW)
     INSPECT WS-KEY TALLYING BT-KEY-LENGTH(WS-ROW) FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE WS-REGISTRY TO BT-REGISTRY(WS-ROW)
     MOVE L-COUNT TO BT-MEMBER-COUNT(WS-ROW)
     SET BT-MEMBER-ADDR(WS-ROW) TO NULL
     IF L-COUNT > 0
         COMPUTE WS-LENGTH = L-COUNT * 4
         ALLOCATE WS-LENGTH CHARACTERS RETURNING WS-ADDR
         SET BT-MEMBER-ADDR(WS-ROW) TO WS-ADDR
         SET ADDRESS OF B-MEMBERS TO WS-ADDR
         SET ADDRESS OF B-SOURCE-IDS TO ADDRESS OF L-IDS
         MOVE B-SOURCE-IDS(1:WS-LENGTH) TO B-MEMBERS(1:WS-LENGTH)
     END-IF
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM TAG-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-TAG-HAS.
*> USING registry (PIC X(48)), tag key (PIC X(64)), entry id (BINARY-LONG), result out (BINARY-LONG: 1 when the
*> element is a member of the tag; 0 otherwise, also for an unknown tag or without an open set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(64).
 01 L-ID                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-ID L-RESULT.
     MOVE 0 TO L-RESULT
     IF CT-OPEN = 0
         GOBACK
     END-IF
     CALL "TAG-FIND" USING L-REGISTRY L-TAG WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
     IF BT-MEMBER-COUNT(WS-ROW) > 0
         SET ADDRESS OF B-MEMBERS TO BT-MEMBER-ADDR(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-MEMBER-COUNT(WS-ROW) OR L-RESULT = 1
             IF BM-ID(WS-I) = L-ID
                 MOVE 1 TO L-RESULT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CONTENT-TAG-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-TAG-MEMBERS.
*> USING registry (PIC X(48)), tag key (PIC X(64)), count out (BINARY-LONG), ids out (a table of BINARY-LONG), capacity
*> (BINARY-LONG entries), status out (CT-OK; CT-NOT-FOUND for an unknown tag, count 0; CT-TOO-SMALL when the
*> table holds fewer ids than the tag has, the count still given and the table left alone; CT-NOT-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 B-TARGET-IDS           PIC X(4194304) BASED.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(64).
 01 L-COUNT                BINARY-LONG.
 01 L-IDS                  BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-COUNT L-IDS L-CAPACITY L-STATUS.
     MOVE 0 TO L-COUNT
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "TAG-FIND" USING L-REGISTRY L-TAG WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
     MOVE BT-MEMBER-COUNT(WS-ROW) TO L-COUNT
     IF L-COUNT > L-CAPACITY
         MOVE CT-TOO-SMALL TO L-STATUS
         GOBACK
     END-IF
     IF L-COUNT > 0
         COMPUTE WS-LENGTH = L-COUNT * 4
         SET ADDRESS OF B-MEMBERS TO BT-MEMBER-ADDR(WS-ROW)
         SET ADDRESS OF B-TARGET-IDS TO ADDRESS OF L-IDS
         MOVE B-MEMBERS(1:WS-LENGTH) TO B-TARGET-IDS(1:WS-LENGTH)
     END-IF
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM CONTENT-TAG-MEMBERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-FREE.
*> No parameters: releases the bound tags of the set and zeroes CT-TAG-COUNT and CT-TAG-ADDR. Safe with none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF CT-TAG-ADDR NOT = NULL
         SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-TAG-COUNT
             IF BT-MEMBER-ADDR(WS-I) NOT = NULL
                 FREE BT-MEMBER-ADDR(WS-I)
             END-IF
         END-PERFORM
         FREE CT-TAG-ADDR
     END-IF
     SET CT-TAG-ADDR TO NULL
     MOVE 0 TO CT-TAG-COUNT
     GOBACK.
 END PROGRAM TAGS-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-REMOVE-REGISTRY.
*> USING registry (PIC X(48)): unbinds every tag of the registry (a later Update Tags payload replaces the
*> registry's tag set, 04 section 1, 23 6.6) and closes the gaps in the tag table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 PROCEDURE DIVISION USING L-REGISTRY.
     IF CT-TAG-ADDR = NULL
         GOBACK
     END-IF
     MOVE L-REGISTRY TO WS-REGISTRY
     MOVE "x" TO WS-KEY
     CALL "TAG-NORMALIZE" USING WS-REGISTRY WS-KEY
     SET ADDRESS OF B-TAGS TO CT-TAG-ADDR
     MOVE 0 TO WS-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-TAG-COUNT
         IF BT-REGISTRY(WS-I) = WS-REGISTRY
             IF BT-MEMBER-ADDR(WS-I) NOT = NULL
                 FREE BT-MEMBER-ADDR(WS-I)
             END-IF
         ELSE
             ADD 1 TO WS-KEPT
             IF WS-KEPT < WS-I
                 MOVE BT-ROW(WS-I) TO BT-ROW(WS-KEPT)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-KEPT TO CT-TAG-COUNT
     GOBACK.
 END PROGRAM TAGS-REMOVE-REGISTRY.
