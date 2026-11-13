*> Implementation test of the nbt_path parser and evaluator (core/src/nbx-path.cob; docs/protocol/15-commands-framework.md §9.5): get (every node kind), set with the creation
*> of missing parents, remove. A negative index counts from the end of the list (not in the docs: gap, recalled behaviour).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBX-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-ROOT                PIC X(256).
 01 WS-PATH                PIC X(256).
 01 WS-VALUE               PIC X(256).
 01 WS-OUT                 PIC X(256).
 01 WS-N                   BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "{a:{b:5}}" TO WS-ROOT
     MOVE "get: two names" TO WS-CASE
     MOVE "a.b" TO WS-PATH
     MOVE "5" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a name that is missing" TO WS-CASE
     MOVE "a.c" TO WS-PATH
     MOVE "none" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a name under a value that is not a compound" TO WS-CASE
     MOVE "a.b.c" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: an index under a compound, all elements of a compound, a filter on a compound" TO WS-CASE
     MOVE "a[0]" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "a[]" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "a[{b:5}]" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "{list:[{x:1},{x:2}]}" TO WS-ROOT
     MOVE "get: an index and a name" TO WS-CASE
     MOVE "list[0].x" TO WS-PATH
     MOVE "1" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a negative index counts from the end" TO WS-CASE
     MOVE "list[-1].x" TO WS-PATH
     MOVE "2" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: all elements" TO WS-CASE
     MOVE "list[].x" TO WS-PATH
     MOVE "1|2" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: elements matching a compound" TO WS-CASE
     MOVE "list[{x:2}]" TO WS-PATH
     MOVE "{x:2}" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: an index out of range" TO WS-CASE
     MOVE "list[5]" TO WS-PATH
     MOVE "none" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a negative index out of range" TO WS-CASE
     MOVE "list[-3]" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a list node on a compound or on a string is nothing" TO WS-CASE
     MOVE "list[0].x[0]" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: the root filter matches" TO WS-CASE
     MOVE "{a:1}" TO WS-ROOT
     MOVE "{a:1}" TO WS-PATH
     MOVE "{a:1}" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: the root filter does not match" TO WS-CASE
     MOVE "{a:2}" TO WS-PATH
     MOVE "none" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a name with a filter, matching and not" TO WS-CASE
     MOVE "{a:{b:1,c:2}}" TO WS-ROOT
     MOVE "a{b:1}" TO WS-PATH
     MOVE "{b:1,c:2}" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "a{b:2}" TO WS-PATH
     MOVE "none" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: a filter on a value that is not a compound" TO WS-CASE
     MOVE "{a:1}" TO WS-ROOT
     MOVE "a{b:2}" TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: quoted names in both quotes" TO WS-CASE
     MOVE '{"a b":3,q:4}' TO WS-ROOT
     MOVE '"a b"' TO WS-PATH
     MOVE "3" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "'q'" TO WS-PATH
     MOVE "4" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: elements of a byte array" TO WS-CASE
     MOVE "{arr:[B;1b,2b,3b]}" TO WS-ROOT
     MOVE "arr[1]" TO WS-PATH
     MOVE "2b" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "arr[]" TO WS-PATH
     MOVE "1b|2b|3b" TO WS-OUT
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT
     MOVE "get: the empty path is the root" TO WS-CASE
     MOVE "{k:1}" TO WS-ROOT
     MOVE "{k:1}" TO WS-OUT
     MOVE SPACES TO WS-PATH
     CALL "TP-GET" USING WS-CASE WS-ROOT WS-PATH WS-OUT

     MOVE "{a:1}" TO WS-ROOT
     MOVE "set: replaces a value" TO WS-CASE
     MOVE "a" TO WS-PATH
     MOVE "5" TO WS-VALUE
     MOVE "{a:5}" TO WS-OUT
     MOVE 1 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: adds a key, even when the value is an empty compound" TO WS-CASE
     MOVE "b" TO WS-PATH
     MOVE "{}" TO WS-VALUE
     MOVE "{a:1,b:{}}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: the same value changes nothing" TO WS-CASE
     MOVE "a" TO WS-PATH
     MOVE "1" TO WS-VALUE
     MOVE "{a:1}" TO WS-OUT
     MOVE 0 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: creates the compounds on the way" TO WS-CASE
     MOVE "{}" TO WS-ROOT
     MOVE "x.y.z" TO WS-PATH
     MOVE "1" TO WS-VALUE
     MOVE "{x:{y:{z:1}}}" TO WS-OUT
     MOVE 1 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: an index, all elements, matching elements" TO WS-CASE
     MOVE "{l:[1,2]}" TO WS-ROOT
     MOVE "l[0]" TO WS-PATH
     MOVE "9" TO WS-VALUE
     MOVE "{l:[9,2]}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "l[]" TO WS-PATH
     MOVE "{l:[9,9]}" TO WS-OUT
     MOVE 2 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "{l:[{x:1},{x:2}]}" TO WS-ROOT
     MOVE "l[{x:2}]" TO WS-PATH
     MOVE "{x:7}" TO WS-VALUE
     MOVE "{l:[{x:1},{x:7}]}" TO WS-OUT
     MOVE 1 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: a key inside an element" TO WS-CASE
     MOVE "{l:[{}]}" TO WS-ROOT
     MOVE "l[0].n" TO WS-PATH
     MOVE "1" TO WS-VALUE
     MOVE "{l:[{n:1}]}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: creates a list and the matching element" TO WS-CASE
     MOVE "{}" TO WS-ROOT
     MOVE "m[{x:1}].y" TO WS-PATH
     MOVE "2" TO WS-VALUE
     MOVE "{m:[{x:1,y:2}]}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: creates a compound from the filter of a name" TO WS-CASE
     MOVE "{}" TO WS-ROOT
     MOVE "a{b:1}.c" TO WS-PATH
     MOVE "5" TO WS-VALUE
     MOVE "{a:{b:1,c:5}}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "set: the root cannot be replaced, nothing is found under a missing index" TO WS-CASE
     MOVE "{a:1}" TO WS-ROOT
     MOVE "{a:1}" TO WS-PATH
     MOVE "{a:2}" TO WS-VALUE
     MOVE "{a:1}" TO WS-OUT
     MOVE 0 TO WS-N
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N
     MOVE "{l:[]}" TO WS-ROOT
     MOVE "l[3].a" TO WS-PATH
     MOVE "{l:[]}" TO WS-OUT
     CALL "TP-SET" USING WS-CASE WS-ROOT WS-PATH WS-VALUE WS-OUT WS-N

     MOVE "{a:1,b:2}" TO WS-ROOT
     MOVE "remove: a key" TO WS-CASE
     MOVE "a" TO WS-PATH
     MOVE "{b:2}" TO WS-OUT
     MOVE 1 TO WS-N
     CALL "TP-REMOVE" USING WS-CASE WS-ROOT WS-PATH WS-OUT WS-N
     MOVE "remove: a key that is missing" TO WS-CASE
     MOVE "z" TO WS-PATH
     MOVE "{a:1,b:2}" TO WS-OUT
     MOVE 0 TO WS-N
     CALL "TP-REMOVE" USING WS-CASE WS-ROOT WS-PATH WS-OUT WS-N
     MOVE "remove: all elements of a list" TO WS-CASE
     MOVE "{l:[1,2,3]}" TO WS-ROOT
     MOVE "l[]" TO WS-PATH
     MOVE "{l:[]}" TO WS-OUT
     MOVE 3 TO WS-N
     CALL "TP-REMOVE" USING WS-CASE WS-ROOT WS-PATH WS-OUT WS-N
     MOVE "remove: one element" TO WS-CASE
     MOVE "{l:[1,2,3]}" TO WS-ROOT
     MOVE "l[1]" TO WS-PATH
     MOVE "{l:[1,3]}" TO WS-OUT
     MOVE 1 TO WS-N
     CALL "TP-REMOVE" USING WS-CASE WS-ROOT WS-PATH WS-OUT WS-N
     MOVE "remove: the root is not removed" TO WS-CASE
     MOVE "{a:1}" TO WS-ROOT
     MOVE "{a:1}" TO WS-PATH
     MOVE "{a:1}" TO WS-OUT
     MOVE 0 TO WS-N
     CALL "TP-REMOVE" USING WS-CASE WS-ROOT WS-PATH WS-OUT WS-N
     GOBACK.
 END PROGRAM TEST-NBX-PATH.

*> TP-LOAD USING root text, path text, root node out, path out: both parsed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TP-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(1024).
 01 WS-START               BINARY-LONG VALUE 0.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 COPY NBXPATH.
 01 L-ROOT                 PIC X(256).
 01 L-PATH                 PIC X(256).
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT L-PATH L-NODE NBX-PATH.
     CALL "TS-PARSE" USING L-ROOT L-NODE
     MOVE SPACES TO WS-TEXT
     MOVE L-PATH TO WS-TEXT
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(L-PATH TRAILING))
     IF L-PATH = SPACES
         MOVE 0 TO WS-END
     END-IF
     CALL "NBX-PATH-PARSE" USING WS-TEXT WS-START WS-END NBX-PATH
     GOBACK.
 END PROGRAM TP-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TP-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXPATH.
 COPY NBXRES.
 COPY NBXTREE.
 01 WS-NODE                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PRINT               PIC X(4096).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-ROOT                 PIC X(256).
 01 L-PATH                 PIC X(256).
 01 L-OUT                  PIC X(256).
 PROCEDURE DIVISION USING L-CASE L-ROOT L-PATH L-OUT.
     CALL "TP-LOAD" USING L-ROOT L-PATH WS-NODE NBX-PATH
     CALL "NBX-PATH-GET" USING WS-NODE NBX-PATH NR-RES
     MOVE SPACES TO WS-PRINT
     MOVE 1 TO WS-POS
     IF NR-COUNT = 0
         STRING "none" DELIMITED BY SIZE INTO WS-PRINT WITH POINTER WS-POS
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NR-COUNT
         IF WS-I > 1
             STRING "|" DELIMITED BY SIZE INTO WS-PRINT WITH POINTER WS-POS
         END-IF
         CALL "NBX-PRINT" USING NR-NODE(WS-I) WS-PRINT WS-POS
     END-PERFORM
     MOVE L-OUT TO WS-TEXT
     CALL "TEST-EXPECT" USING L-CASE WS-TEXT WS-PRINT
     CALL "NBX-PATH-FREE" USING NBX-PATH
     CALL "NBX-FREE" USING WS-NODE
     GOBACK.
 END PROGRAM TP-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TP-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXPATH.
 01 WS-NODE                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-OBSERVED            BINARY-DOUBLE.
 01 WS-CASE-2              PIC X(240).
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-ROOT                 PIC X(256).
 01 L-PATH                 PIC X(256).
 01 L-VALUE                PIC X(256).
 01 L-OUT                  PIC X(256).
 01 L-CHANGED              BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CASE L-ROOT L-PATH L-VALUE L-OUT L-CHANGED.
     CALL "TP-LOAD" USING L-ROOT L-PATH WS-NODE NBX-PATH
     CALL "TS-PARSE" USING L-VALUE WS-VALUE
     CALL "NBX-PATH-SET" USING WS-NODE NBX-PATH WS-VALUE WS-CHANGED
     CALL "TS-SHOW" USING L-CASE WS-NODE L-OUT
     MOVE WS-CHANGED TO WS-OBSERVED
     MOVE SPACES TO WS-CASE-2
     STRING "changed: " DELIMITED BY SIZE L-CASE DELIMITED BY SIZE INTO WS-CASE-2
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE-2 L-CHANGED WS-OBSERVED
     CALL "NBX-PATH-FREE" USING NBX-PATH
     CALL "NBX-FREE" USING WS-NODE
     CALL "NBX-FREE" USING WS-VALUE
     GOBACK.
 END PROGRAM TP-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TP-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXPATH.
 01 WS-NODE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OBSERVED            BINARY-DOUBLE.
 01 WS-CASE-2              PIC X(240).
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-ROOT                 PIC X(256).
 01 L-PATH                 PIC X(256).
 01 L-OUT                  PIC X(256).
 01 L-COUNT                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CASE L-ROOT L-PATH L-OUT L-COUNT.
     CALL "TP-LOAD" USING L-ROOT L-PATH WS-NODE NBX-PATH
     CALL "NBX-PATH-REMOVE" USING WS-NODE NBX-PATH WS-COUNT
     CALL "TS-SHOW" USING L-CASE WS-NODE L-OUT
     MOVE WS-COUNT TO WS-OBSERVED
     MOVE SPACES TO WS-CASE-2
     STRING "count: " DELIMITED BY SIZE L-CASE DELIMITED BY SIZE INTO WS-CASE-2
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE-2 L-COUNT WS-OBSERVED
     CALL "NBX-PATH-FREE" USING NBX-PATH
     CALL "NBX-FREE" USING WS-NODE
     GOBACK.
 END PROGRAM TP-REMOVE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY NBXTEST.
