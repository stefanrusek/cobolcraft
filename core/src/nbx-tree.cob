*> The NBT value tree (core/copy/NBXTREE.cpy): nodes from one pool, compounds, lists and arrays as chains of children. Entry points:
*>   NBX-NEW USING type, node out: a fresh node of that type (the sink node, with NX-FULL set, when the pool is full)
*>   NBX-FREE USING node: the node and everything below it return to the pool (the sink is never pooled)
*>   NBX-ADD USING parent, child: the child becomes the last child of the parent (the sink is not added)
*>   NBX-UNLINK USING node: the node leaves its parent's chain (it stays allocated)
*>   NBX-FIND USING compound, key (PIC X(64)), key length, node out (0 = none)
*>   NBX-SUBST USING old, new: the new node takes the place and the key of the old one in its parent, which is freed
*>   NBX-SET USING compound, key, key length, child: the entry of that key becomes the child (replaced in place or appended)
*>   NBX-CLONE USING node, copy out: a deep copy without a parent
*>   NBX-EQUAL USING a, b, partial (1: a is a subset of b, as the nbt selector option and the path filters match), result out (1 equal)
*>   NBX-MERGE USING target compound, source compound, changed out: the entries of the source merged into the target (compounds merge,
*>     other values replace); changed is 1 when anything differed

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-NEW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-NODE.
     EVALUATE TRUE
         WHEN NX-FREE-HEAD > 0
             MOVE NX-FREE-HEAD TO L-NODE
             MOVE NX-NEXT(L-NODE) TO NX-FREE-HEAD
         WHEN NX-TOP < NX-MAX
             ADD 1 TO NX-TOP
             MOVE NX-TOP TO L-NODE
         WHEN OTHER
             MOVE NX-SINK TO L-NODE
             MOVE 1 TO NX-FULL
     END-EVALUATE
     MOVE L-TYPE TO NX-TYPE(L-NODE)
     MOVE 0 TO NX-NEXT(L-NODE) NX-FIRST(L-NODE) NX-LAST(L-NODE) NX-PARENT(L-NODE) NX-COUNT(L-NODE)
     MOVE 0 TO NX-KLEN(L-NODE) NX-SLEN(L-NODE) NX-INT(L-NODE) NX-DBL(L-NODE)
     MOVE SPACES TO NX-KEY(L-NODE) NX-STR(L-NODE)
     GOBACK.
 END PROGRAM NBX-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-FREE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE.
     MOVE NX-FIRST(L-NODE) TO LS-CHILD
     PERFORM UNTIL LS-CHILD = 0
         MOVE NX-NEXT(LS-CHILD) TO LS-NEXT
         CALL "NBX-FREE" USING LS-CHILD
         MOVE LS-NEXT TO LS-CHILD
     END-PERFORM
     IF L-NODE NOT = NX-SINK
         MOVE 0 TO NX-TYPE(L-NODE)
         MOVE NX-FREE-HEAD TO NX-NEXT(L-NODE)
         MOVE L-NODE TO NX-FREE-HEAD
     END-IF
     GOBACK.
 END PROGRAM NBX-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 LINKAGE SECTION.
 01 L-PARENT               BINARY-LONG.
 01 L-CHILD                BINARY-LONG.
 PROCEDURE DIVISION USING L-PARENT L-CHILD.
     IF L-CHILD NOT = NX-SINK
         MOVE 0 TO NX-NEXT(L-CHILD)
         MOVE L-PARENT TO NX-PARENT(L-CHILD)
         IF NX-LAST(L-PARENT) = 0
             MOVE L-CHILD TO NX-FIRST(L-PARENT)
         ELSE
             MOVE L-CHILD TO NX-NEXT(NX-LAST(L-PARENT))
         END-IF
         MOVE L-CHILD TO NX-LAST(L-PARENT)
         ADD 1 TO NX-COUNT(L-PARENT)
     END-IF
     GOBACK.
 END PROGRAM NBX-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-UNLINK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-PARENT              BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE.
     MOVE NX-PARENT(L-NODE) TO WS-PARENT
     MOVE 0 TO WS-PREV
     MOVE NX-FIRST(WS-PARENT) TO WS-CUR
     PERFORM UNTIL WS-CUR = L-NODE
         MOVE WS-CUR TO WS-PREV
         MOVE NX-NEXT(WS-CUR) TO WS-CUR
     END-PERFORM
     IF WS-PREV = 0
         MOVE NX-NEXT(L-NODE) TO NX-FIRST(WS-PARENT)
     ELSE
         MOVE NX-NEXT(L-NODE) TO NX-NEXT(WS-PREV)
     END-IF
     IF NX-LAST(WS-PARENT) = L-NODE
         MOVE WS-PREV TO NX-LAST(WS-PARENT)
     END-IF
     SUBTRACT 1 FROM NX-COUNT(WS-PARENT)
     MOVE 0 TO NX-NEXT(L-NODE) NX-PARENT(L-NODE)
     GOBACK.
 END PROGRAM NBX-UNLINK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 LINKAGE SECTION.
 01 L-COMPOUND             BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-KLEN                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COMPOUND L-KEY L-KLEN L-NODE.
     MOVE 0 TO L-NODE
     MOVE NX-FIRST(L-COMPOUND) TO L-NODE
     PERFORM UNTIL L-NODE = 0 OR (NX-KLEN(L-NODE) = L-KLEN AND NX-KEY(L-NODE) = L-KEY)
         MOVE NX-NEXT(L-NODE) TO L-NODE
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-SUBST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-PARENT              BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW.
     MOVE NX-PARENT(L-OLD) TO WS-PARENT
     MOVE 0 TO WS-PREV
     MOVE NX-FIRST(WS-PARENT) TO WS-CUR
     PERFORM UNTIL WS-CUR = L-OLD
         MOVE WS-CUR TO WS-PREV
         MOVE NX-NEXT(WS-CUR) TO WS-CUR
     END-PERFORM
     MOVE NX-NEXT(L-OLD) TO NX-NEXT(L-NEW)
     MOVE WS-PARENT TO NX-PARENT(L-NEW)
     MOVE NX-KLEN(L-OLD) TO NX-KLEN(L-NEW)
     MOVE NX-KEY(L-OLD) TO NX-KEY(L-NEW)
     IF WS-PREV = 0
         MOVE L-NEW TO NX-FIRST(WS-PARENT)
     ELSE
         MOVE L-NEW TO NX-NEXT(WS-PREV)
     END-IF
     IF NX-LAST(WS-PARENT) = L-OLD
         MOVE L-NEW TO NX-LAST(WS-PARENT)
     END-IF
     MOVE 0 TO NX-NEXT(L-OLD) NX-PARENT(L-OLD)
     CALL "NBX-FREE" USING L-OLD
     GOBACK.
 END PROGRAM NBX-SUBST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-COMPOUND             BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-KLEN                 BINARY-LONG.
 01 L-CHILD                BINARY-LONG.
 PROCEDURE DIVISION USING L-COMPOUND L-KEY L-KLEN L-CHILD.
     CALL "NBX-FIND" USING L-COMPOUND L-KEY L-KLEN WS-OLD
     IF WS-OLD > 0
         CALL "NBX-SUBST" USING WS-OLD L-CHILD
     ELSE
         MOVE L-KEY TO NX-KEY(L-CHILD)
         MOVE L-KLEN TO NX-KLEN(L-CHILD)
         CALL "NBX-ADD" USING L-COMPOUND L-CHILD
     END-IF
     GOBACK.
 END PROGRAM NBX-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-CLONE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-COPY                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-COPY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-COPY.
     CALL "NBX-NEW" USING NX-TYPE(L-NODE) L-COPY
     MOVE NX-KLEN(L-NODE) TO NX-KLEN(L-COPY)
     MOVE NX-KEY(L-NODE) TO NX-KEY(L-COPY)
     MOVE NX-SLEN(L-NODE) TO NX-SLEN(L-COPY)
     MOVE NX-INT(L-NODE) TO NX-INT(L-COPY)
     MOVE NX-DBL(L-NODE) TO NX-DBL(L-COPY)
     MOVE NX-STR(L-NODE) TO NX-STR(L-COPY)
     MOVE NX-FIRST(L-NODE) TO LS-CHILD
     PERFORM UNTIL LS-CHILD = 0
         CALL "NBX-CLONE" USING LS-CHILD LS-COPY
         CALL "NBX-ADD" USING L-COPY LS-COPY
         MOVE NX-NEXT(LS-CHILD) TO LS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-CLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-EQUAL RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD-A             BINARY-LONG.
 01 LS-CHILD-B             BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-KEY                 PIC X(64).
 01 LS-KLEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-PARTIAL              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-PARTIAL L-RESULT.
     MOVE 0 TO L-RESULT
     IF NX-TYPE(L-A) = NX-TYPE(L-B)
         EVALUATE TRUE
             WHEN NX-TYPE(L-A) <= 4
                 IF NX-INT(L-A) = NX-INT(L-B)
                     MOVE 1 TO L-RESULT
                 END-IF
             WHEN NX-TYPE(L-A) <= 6
                 IF NX-DBL(L-A) = NX-DBL(L-B)
                     MOVE 1 TO L-RESULT
                 END-IF
             WHEN NX-TYPE(L-A) = 8
                 IF NX-SLEN(L-A) = NX-SLEN(L-B) AND NX-STR(L-A) = NX-STR(L-B)
                     MOVE 1 TO L-RESULT
                 END-IF
             WHEN NX-TYPE(L-A) = 10
                 MOVE 1 TO LS-OK
                 IF L-PARTIAL = 0 AND NX-COUNT(L-A) NOT = NX-COUNT(L-B)
                     MOVE 0 TO LS-OK
                 END-IF
                 MOVE NX-FIRST(L-A) TO LS-CHILD-A
                 PERFORM UNTIL LS-CHILD-A = 0 OR LS-OK = 0
                     MOVE NX-KEY(LS-CHILD-A) TO LS-KEY
                     MOVE NX-KLEN(LS-CHILD-A) TO LS-KLEN
                     CALL "NBX-FIND" USING L-B LS-KEY LS-KLEN LS-CHILD-B
                     IF LS-CHILD-B = 0
                         MOVE 0 TO LS-OK
                     ELSE
                         CALL "NBX-EQUAL" USING LS-CHILD-A LS-CHILD-B L-PARTIAL LS-SUB
                         MOVE LS-SUB TO LS-OK
                     END-IF
                     MOVE NX-NEXT(LS-CHILD-A) TO LS-CHILD-A
                 END-PERFORM
                 MOVE LS-OK TO L-RESULT
             WHEN L-PARTIAL = 1 AND NX-TYPE(L-A) = 9
                 MOVE 1 TO LS-OK
                 MOVE NX-FIRST(L-A) TO LS-CHILD-A
                 PERFORM UNTIL LS-CHILD-A = 0 OR LS-OK = 0
                     MOVE 0 TO LS-FOUND
                     MOVE NX-FIRST(L-B) TO LS-CHILD-B
                     PERFORM UNTIL LS-CHILD-B = 0 OR LS-FOUND = 1
                         CALL "NBX-EQUAL" USING LS-CHILD-A LS-CHILD-B L-PARTIAL LS-FOUND
                         MOVE NX-NEXT(LS-CHILD-B) TO LS-CHILD-B
                     END-PERFORM
                     MOVE LS-FOUND TO LS-OK
                     MOVE NX-NEXT(LS-CHILD-A) TO LS-CHILD-A
                 END-PERFORM
                 MOVE LS-OK TO L-RESULT
             WHEN OTHER
                 MOVE 1 TO LS-OK
                 IF NX-COUNT(L-A) NOT = NX-COUNT(L-B)
                     MOVE 0 TO LS-OK
                 END-IF
                 MOVE NX-FIRST(L-A) TO LS-CHILD-A
                 MOVE NX-FIRST(L-B) TO LS-CHILD-B
                 PERFORM UNTIL LS-CHILD-A = 0 OR LS-OK = 0
                     CALL "NBX-EQUAL" USING LS-CHILD-A LS-CHILD-B L-PARTIAL LS-SUB
                     MOVE LS-SUB TO LS-OK
                     MOVE NX-NEXT(LS-CHILD-A) TO LS-CHILD-A
                     MOVE NX-NEXT(LS-CHILD-B) TO LS-CHILD-B
                 END-PERFORM
                 MOVE LS-OK TO L-RESULT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM NBX-EQUAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-MERGE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-S                   BINARY-LONG.
 01 LS-T                   BINARY-LONG.
 01 LS-COPY                BINARY-LONG.
 01 LS-SAME                BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-KEY                 PIC X(64).
 01 LS-KLEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TARGET               BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGET L-SOURCE L-CHANGED.
     MOVE 0 TO L-CHANGED
     MOVE NX-FIRST(L-SOURCE) TO LS-S
     PERFORM UNTIL LS-S = 0
         MOVE NX-KEY(LS-S) TO LS-KEY
         MOVE NX-KLEN(LS-S) TO LS-KLEN
         CALL "NBX-FIND" USING L-TARGET LS-KEY LS-KLEN LS-T
         IF LS-T > 0 AND NX-TYPE(LS-T) = 10 AND NX-TYPE(LS-S) = 10
             CALL "NBX-MERGE" USING LS-T LS-S LS-SUB
             IF LS-SUB = 1
                 MOVE 1 TO L-CHANGED
             END-IF
         ELSE
             MOVE 0 TO LS-SAME
             IF LS-T > 0
                 CALL "NBX-EQUAL" USING LS-T LS-S WS-ZERO LS-SAME
             END-IF
             IF LS-SAME = 0
                 CALL "NBX-CLONE" USING LS-S LS-COPY
                 CALL "NBX-SET" USING L-TARGET LS-KEY LS-KLEN LS-COPY
                 MOVE 1 TO L-CHANGED
             END-IF
         END-IF
         MOVE NX-NEXT(LS-S) TO LS-S
     END-PERFORM
     GOBACK.
 END PROGRAM NBX-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBX-INSERT.
*> USING list, node, position: the node becomes the child at that 0-based position of the list (appended when the position is at or past the end).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-PREV                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-POSITION             BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-NODE L-POSITION.
     MOVE 0 TO WS-PREV
     MOVE NX-FIRST(L-LIST) TO WS-CUR
     MOVE L-POSITION TO WS-I
     PERFORM UNTIL WS-I <= 0 OR WS-CUR = 0
         MOVE WS-CUR TO WS-PREV
         MOVE NX-NEXT(WS-CUR) TO WS-CUR
         SUBTRACT 1 FROM WS-I
     END-PERFORM
     EVALUATE TRUE
         WHEN L-NODE = NX-SINK
             CONTINUE
         WHEN WS-CUR = 0
             CALL "NBX-ADD" USING L-LIST L-NODE
         WHEN OTHER
             MOVE WS-CUR TO NX-NEXT(L-NODE)
             MOVE L-LIST TO NX-PARENT(L-NODE)
             IF WS-PREV = 0
                 MOVE L-NODE TO NX-FIRST(L-LIST)
             ELSE
                 MOVE L-NODE TO NX-NEXT(WS-PREV)
             END-IF
             ADD 1 TO NX-COUNT(L-LIST)
     END-EVALUATE
     GOBACK.
 END PROGRAM NBX-INSERT.
