*> The nbt_path parser and evaluator (docs/protocol/15-commands-framework.md §9.5; core/copy/NBXPATH.cpy, NBXRES.cpy). The parser trusts text the
*> recogniser BR-ARG-NBT-PATH accepted. A negative index counts from the end of the list (the docs do not read this: recalled behaviour, gap); a
*> set creates the missing compounds (a list when the next node is a list node) on the way, a name with a filter creates a copy of the filter,
*> a [{..}] node with no match creates a copy of the filter. Entry points:
*>   NBX-PATH-PARSE USING text (PIC X(1024)), start, end (0-based offsets), NBX-PATH out
*>   NBX-PATH-FREE USING NBX-PATH: frees the filters
*>   NBX-PATH-STEP USING NBX-PATH, entry, node, create (0, 1 intermediate: make what is missing, 2 last node: make a placeholder for a missing name), NR-RES (appended)
*>   NBX-PATH-GET USING root, NBX-PATH, NR-RES out: the nodes the whole path matches
*>   NBX-PATH-SET USING root, NBX-PATH, value (a node, copied), changed out: the matched nodes that differed were replaced
*>   NBX-PATH-REMOVE USING root, NBX-PATH, removed out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-PARSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY NBXTREE.
 01 WS-CH                  PIC X.
 01 WS-STR                 PIC X(1024).
 01 WS-LEN                 BINARY-LONG.
 01 WS-VAL                 BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 COPY NBXPATH.
 PROCEDURE DIVISION USING L-TEXT L-START L-END NBX-PATH.
     MOVE L-TEXT TO BR-IN-TEXT
     MOVE L-END TO BR-IN-LENGTH
     MOVE L-START TO BR-IN-CURSOR
     MOVE 0 TO NP-COUNT
     PERFORM UNTIL BR-IN-CURSOR >= BR-IN-LENGTH
         ADD 1 TO NP-COUNT
         MOVE 0 TO NP-FILTER(NP-COUNT) NP-INDEX(NP-COUNT) NP-KLEN(NP-COUNT)
         MOVE SPACES TO NP-KEY(NP-COUNT)
         MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
         EVALUATE TRUE
             WHEN WS-CH = "{"
                 MOVE 1 TO NP-KIND(NP-COUNT)
                 CALL "NBX-PARSE-VALUE" USING NP-FILTER(NP-COUNT)
             WHEN WS-CH = "["
                 ADD 1 TO BR-IN-CURSOR
                 MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
                 EVALUATE TRUE
                     WHEN WS-CH = "{"
                         MOVE 5 TO NP-KIND(NP-COUNT)
                         CALL "NBX-PARSE-VALUE" USING NP-FILTER(NP-COUNT)
                     WHEN WS-CH = "]"
                         MOVE 4 TO NP-KIND(NP-COUNT)
                     WHEN OTHER
                         MOVE 6 TO NP-KIND(NP-COUNT)
                         MOVE 0 TO WS-VAL WS-NEG
                         IF WS-CH = "-"
                             MOVE 1 TO WS-NEG
                             ADD 1 TO BR-IN-CURSOR
                         END-IF
                         PERFORM UNTIL BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT NUMERIC
                             COMPUTE WS-VAL = WS-VAL * 10 + FUNCTION ORD(BR-IN-TEXT(BR-IN-CURSOR + 1:1)) - 49
                             ADD 1 TO BR-IN-CURSOR
                         END-PERFORM
                         IF WS-NEG = 1
                             COMPUTE WS-VAL = 0 - WS-VAL
                         END-IF
                         MOVE WS-VAL TO NP-INDEX(NP-COUNT)
                 END-EVALUATE
                 ADD 1 TO BR-IN-CURSOR
             WHEN OTHER
                 MOVE 2 TO NP-KIND(NP-COUNT)
                 IF WS-CH = '"' OR WS-CH = "'"
                     CALL "BR-SNBT-STRING" USING BR-IN-CURSOR WS-STR WS-LEN
                 ELSE
                     MOVE BR-IN-CURSOR TO WS-START
                     PERFORM UNTIL BR-IN-CURSOR >= BR-IN-LENGTH
                             OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = SPACE OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = '"'
                             OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "'" OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "["
                             OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]" OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "."
                             OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{" OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "}"
                         ADD 1 TO BR-IN-CURSOR
                     END-PERFORM
                     COMPUTE WS-LEN = BR-IN-CURSOR - WS-START
                     MOVE SPACES TO WS-STR
                     MOVE BR-IN-TEXT(WS-START + 1:WS-LEN) TO WS-STR(1:WS-LEN)
                 END-IF
                 MOVE WS-STR TO NP-KEY(NP-COUNT)
                 COMPUTE NP-KLEN(NP-COUNT) = FUNCTION MIN(WS-LEN, 64)
                 IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
                     MOVE 3 TO NP-KIND(NP-COUNT)
                     CALL "NBX-PARSE-VALUE" USING NP-FILTER(NP-COUNT)
                 END-IF
         END-EVALUATE
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "."
             ADD 1 TO BR-IN-CURSOR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-PATH-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-FREE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY NBXPATH.
 PROCEDURE DIVISION USING NBX-PATH.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NP-COUNT
         IF NP-FILTER(WS-I) > 0
             CALL "NBX-FREE" USING NP-FILTER(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO NP-COUNT
     GOBACK.
 END PROGRAM NBX-PATH-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-RES-ADD.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY NBXRES.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING NR-RES L-NODE.
     IF NR-COUNT < 512
         ADD 1 TO NR-COUNT
         MOVE L-NODE TO NR-NODE(NR-COUNT)
     END-IF
     GOBACK.
 END PROGRAM NBX-RES-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-CHILD               BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KLEN                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-NEXT-KIND           BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LISTY               BINARY-LONG.
 LINKAGE SECTION.
 COPY NBXPATH.
 01 L-ENTRY                BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 COPY NBXRES.
 PROCEDURE DIVISION USING NBX-PATH L-ENTRY L-NODE L-CREATE NR-RES.
     MOVE NP-KIND(L-ENTRY) TO WS-KIND
     MOVE NP-FILTER(L-ENTRY) TO WS-FILTER
     MOVE NP-KEY(L-ENTRY) TO WS-KEY
     MOVE NP-KLEN(L-ENTRY) TO WS-KLEN
     MOVE NP-INDEX(L-ENTRY) TO WS-INDEX
     MOVE 0 TO WS-NEXT-KIND
     IF L-ENTRY < NP-COUNT
         COMPUTE WS-CHILD = L-ENTRY + 1
         MOVE NP-KIND(WS-CHILD) TO WS-NEXT-KIND
     END-IF
     MOVE 0 TO WS-LISTY
     IF NX-TYPE(L-NODE) = 9 OR NX-TYPE(L-NODE) = 7 OR NX-TYPE(L-NODE) >= 11
         MOVE 1 TO WS-LISTY
     END-IF
     EVALUATE WS-KIND
         WHEN 1
             IF NX-TYPE(L-NODE) = 10
                 CALL "NBX-EQUAL" USING WS-FILTER L-NODE WS-ONE WS-MATCH
                 IF WS-MATCH = 1
                     CALL "NBX-RES-ADD" USING NR-RES L-NODE
                 END-IF
             END-IF
         WHEN 2
             IF NX-TYPE(L-NODE) = 10
                 CALL "NBX-FIND" USING L-NODE WS-KEY WS-KLEN WS-CHILD
                 IF WS-CHILD = 0 AND L-CREATE = 1
                     IF WS-NEXT-KIND >= 4
                         CALL "NBX-NEW" USING WS-T-LIST WS-CHILD
                     ELSE
                         CALL "NBX-NEW" USING WS-T-COMPOUND WS-CHILD
                     END-IF
                     CALL "NBX-SET" USING L-NODE WS-KEY WS-KLEN WS-CHILD
                 END-IF
                 IF WS-CHILD = 0 AND L-CREATE = 2
                     CALL "NBX-NEW" USING WS-T-NONE WS-CHILD
                     CALL "NBX-SET" USING L-NODE WS-KEY WS-KLEN WS-CHILD
                 END-IF
                 IF WS-CHILD > 0
                     CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                 END-IF
             END-IF
         WHEN 3
             IF NX-TYPE(L-NODE) = 10
                 CALL "NBX-FIND" USING L-NODE WS-KEY WS-KLEN WS-CHILD
                 IF WS-CHILD = 0 AND L-CREATE = 1
                     CALL "NBX-CLONE" USING WS-FILTER WS-CHILD
                     CALL "NBX-SET" USING L-NODE WS-KEY WS-KLEN WS-CHILD
                 END-IF
                 IF WS-CHILD > 0
                     IF NX-TYPE(WS-CHILD) = 10
                         CALL "NBX-EQUAL" USING WS-FILTER WS-CHILD WS-ONE WS-MATCH
                         IF WS-MATCH = 1
                             CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                         END-IF
                     END-IF
                 END-IF
             END-IF
         WHEN 4
             IF WS-LISTY = 1
                 MOVE NX-FIRST(L-NODE) TO WS-CHILD
                 PERFORM UNTIL WS-CHILD = 0
                     CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                     MOVE NX-NEXT(WS-CHILD) TO WS-CHILD
                 END-PERFORM
             END-IF
         WHEN 5
             IF NX-TYPE(L-NODE) = 9
                 MOVE 0 TO WS-FOUND
                 MOVE NX-FIRST(L-NODE) TO WS-CHILD
                 PERFORM UNTIL WS-CHILD = 0
                     CALL "NBX-EQUAL" USING WS-FILTER WS-CHILD WS-ONE WS-MATCH
                     IF WS-MATCH = 1
                         CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                         MOVE 1 TO WS-FOUND
                     END-IF
                     MOVE NX-NEXT(WS-CHILD) TO WS-CHILD
                 END-PERFORM
                 IF WS-FOUND = 0 AND L-CREATE = 1
                     CALL "NBX-CLONE" USING WS-FILTER WS-CHILD
                     CALL "NBX-ADD" USING L-NODE WS-CHILD
                     CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                 END-IF
             END-IF
         WHEN OTHER
             IF WS-LISTY = 1
                 IF WS-INDEX < 0
                     ADD NX-COUNT(L-NODE) TO WS-INDEX
                 END-IF
                 MOVE NX-FIRST(L-NODE) TO WS-CHILD
                 PERFORM UNTIL WS-CHILD = 0 OR WS-INDEX <= 0
                     MOVE NX-NEXT(WS-CHILD) TO WS-CHILD
                     SUBTRACT 1 FROM WS-INDEX
                 END-PERFORM
                 IF WS-CHILD > 0 AND WS-INDEX = 0
                     CALL "NBX-RES-ADD" USING NR-RES WS-CHILD
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM NBX-PATH-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXRES REPLACING LEADING ==NR-== BY ==NA-==.
 COPY NBXRES REPLACING LEADING ==NR-== BY ==NB-==.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 COPY NBXPATH.
 COPY NBXRES.
 PROCEDURE DIVISION USING L-ROOT NBX-PATH NR-RES.
     MOVE 1 TO NA-COUNT
     MOVE L-ROOT TO NA-NODE(1)
     PERFORM VARYING WS-ENTRY FROM 1 BY 1 UNTIL WS-ENTRY > NP-COUNT
         MOVE 0 TO NB-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > NA-COUNT
             CALL "NBX-PATH-STEP" USING NBX-PATH WS-ENTRY NA-NODE(WS-K) WS-ZERO NB-RES
         END-PERFORM
         MOVE NB-RES TO NA-RES
     END-PERFORM
     MOVE NA-RES TO NR-RES
     GOBACK.
 END PROGRAM NBX-PATH-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXRES REPLACING LEADING ==NR-== BY ==NA-==.
 COPY NBXRES REPLACING LEADING ==NR-== BY ==NB-==.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CREATE              BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 COPY NBXPATH.
 01 L-VALUE                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT NBX-PATH L-VALUE L-CHANGED.
     MOVE 0 TO L-CHANGED
     MOVE 1 TO NA-COUNT
     MOVE L-ROOT TO NA-NODE(1)
     PERFORM VARYING WS-ENTRY FROM 1 BY 1 UNTIL WS-ENTRY > NP-COUNT
         MOVE 1 TO WS-CREATE
         IF WS-ENTRY = NP-COUNT
             MOVE 2 TO WS-CREATE
         END-IF
         MOVE 0 TO NB-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > NA-COUNT
             CALL "NBX-PATH-STEP" USING NBX-PATH WS-ENTRY NA-NODE(WS-K) WS-CREATE NB-RES
         END-PERFORM
         MOVE NB-RES TO NA-RES
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > NA-COUNT
         IF NX-PARENT(NA-NODE(WS-K)) > 0
             CALL "NBX-EQUAL" USING NA-NODE(WS-K) L-VALUE WS-ZERO WS-SAME
             IF WS-SAME = 0
                 CALL "NBX-CLONE" USING L-VALUE WS-COPY
                 CALL "NBX-SUBST" USING NA-NODE(WS-K) WS-COPY
                 ADD 1 TO L-CHANGED
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-PATH-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-PATH-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXRES.
 01 WS-K                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 COPY NBXPATH.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT NBX-PATH L-REMOVED.
     CALL "NBX-PATH-GET" USING L-ROOT NBX-PATH NR-RES
     MOVE 0 TO L-REMOVED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > NR-COUNT
         MOVE NR-NODE(WS-K) TO WS-NODE
         IF NX-PARENT(WS-NODE) > 0
             CALL "NBX-UNLINK" USING WS-NODE
             CALL "NBX-FREE" USING WS-NODE
             ADD 1 TO L-REMOVED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-PATH-REMOVE.
