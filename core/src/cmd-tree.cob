*> The command tree of the Brigadier-style framework (docs/protocol/15-commands-framework.md §3,
*> 15a-brigadier-command-library.md §2; core/copy/BRIGADIER.cpy). Node 1 is the root; children of a
*> node are a linked list in insertion order; a literal and an argument share one name space.
*>
*> Entry points:
*>   BR-TREE-RESET                      an empty tree (the root only)
*>   BR-ADD-NODE USING parent, kind (BR-LITERAL or BR-ARGUMENT), name (PIC X(32)), name length, parser
*>     id (arguments), node out (0 = the table is full), created out (1 new, 0 an existing child of
*>     that name: 15a §2.3, the old node is kept with its attributes and the caller must not change
*>     them, only add a command to it and children under it)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-TREE-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 PROCEDURE DIVISION.
     INITIALIZE BR-TREE
     MOVE 1 TO BR-NODE-COUNT
     GOBACK.
 END PROGRAM BR-TREE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ADD-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-CHILD               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PARENT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PARENT L-KIND L-NAME L-NAME-LENGTH L-TYPE L-NODE L-CREATED.
     MOVE 0 TO L-NODE L-CREATED
     MOVE BR-N-FIRST(L-PARENT) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0 OR L-NODE > 0
         IF BR-N-NAME-LENGTH(WS-CHILD) = L-NAME-LENGTH
                 AND BR-N-NAME(WS-CHILD)(1:L-NAME-LENGTH) = L-NAME(1:L-NAME-LENGTH)
             MOVE WS-CHILD TO L-NODE
         ELSE
             MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
         END-IF
     END-PERFORM
     IF L-NODE = 0 AND BR-NODE-COUNT < BR-MAX-NODES
         ADD 1 TO BR-NODE-COUNT
         MOVE BR-NODE-COUNT TO L-NODE
         MOVE 1 TO L-CREATED
         INITIALIZE BR-NODE(L-NODE)
         MOVE L-KIND TO BR-N-KIND(L-NODE)
         MOVE L-NAME-LENGTH TO BR-N-NAME-LENGTH(L-NODE)
         MOVE L-NAME(1:L-NAME-LENGTH) TO BR-N-NAME(L-NODE)
         MOVE L-TYPE TO BR-N-TYPE(L-NODE)
         IF BR-N-LAST(L-PARENT) = 0
             MOVE L-NODE TO BR-N-FIRST(L-PARENT)
         ELSE
             MOVE L-NODE TO BR-N-NEXT(BR-N-LAST(L-PARENT))
         END-IF
         MOVE L-NODE TO BR-N-LAST(L-PARENT)
     END-IF
     GOBACK.
 END PROGRAM BR-ADD-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-TREE-BUILD.
*> USING permission level (0 to 4), PB-BUFFER: Commands 0x10 (05a) for a source of that level
*> (15 §3.3, §3.4): a filtered copy of the tree, depth first, a child copied only when its
*> requirement level is held, its redirect kept only when the target was copied before it; the
*> nodes numbered breadth first from the root (0; children in order, then the redirect target);
*> flags: type, 0x04 executable, 0x08 redirect, 0x10 custom suggestions (ask_server), 0x20 restricted
*> (the node's own requirement fails for a source with no permission, so level above 0); then the
*> root index 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 16.
 01 WS-ROOT-INDEX          BINARY-LONG VALUE 0.
 01 WS-SUGGEST             PIC X(20) VALUE "minecraft:ask_server".
 01 WS-COPY.
    05 WS-INCLUDED          BINARY-LONG OCCURS 1024 TIMES.
    05 WS-KEEP-REDIRECT     BINARY-LONG OCCURS 1024 TIMES.
    05 WS-INDEX             BINARY-LONG OCCURS 1024 TIMES.   *> wire index + 1, 0 = not numbered
    05 WS-ORDER             BINARY-LONG OCCURS 1024 TIMES.   *> node of wire index i - 1
 01 WS-STACK.
    05 WS-STACK-NODE        BINARY-LONG OCCURS 64 TIMES.
    05 WS-STACK-CHILD       BINARY-LONG OCCURS 64 TIMES.
 01 WS-QUEUE.
    05 WS-Q                 BINARY-LONG OCCURS 2048 TIMES.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL PB-BUFFER.
     INITIALIZE WS-COPY
     MOVE 1 TO WS-INCLUDED(1)
     PERFORM COPY-TREE
     PERFORM NUMBER-NODES
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         PERFORM PUT-NODE
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ROOT-INDEX
     GOBACK.

 COPY-TREE.
     MOVE 1 TO WS-DEPTH
     MOVE 1 TO WS-STACK-NODE(1)
     MOVE BR-N-FIRST(1) TO WS-STACK-CHILD(1)
     PERFORM UNTIL WS-DEPTH = 0
         MOVE WS-STACK-CHILD(WS-DEPTH) TO WS-CHILD
         IF WS-CHILD = 0
             SUBTRACT 1 FROM WS-DEPTH
         ELSE
             MOVE BR-N-NEXT(WS-CHILD) TO WS-STACK-CHILD(WS-DEPTH)
             IF BR-N-LEVEL(WS-CHILD) <= L-LEVEL
                 MOVE 1 TO WS-INCLUDED(WS-CHILD)
                 IF BR-N-REDIRECT(WS-CHILD) > 0
                     MOVE WS-INCLUDED(BR-N-REDIRECT(WS-CHILD)) TO WS-KEEP-REDIRECT(WS-CHILD)
                 END-IF
                 IF BR-N-FIRST(WS-CHILD) > 0
                     ADD 1 TO WS-DEPTH
                     MOVE WS-CHILD TO WS-STACK-NODE(WS-DEPTH)
                     MOVE BR-N-FIRST(WS-CHILD) TO WS-STACK-CHILD(WS-DEPTH)
                 END-IF
             END-IF
         END-IF
     END-PERFORM.

 NUMBER-NODES.
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE 1 TO WS-Q(1)
     MOVE 0 TO WS-COUNT
     PERFORM UNTIL WS-HEAD > WS-TAIL
         MOVE WS-Q(WS-HEAD) TO WS-N
         ADD 1 TO WS-HEAD
         IF WS-INDEX(WS-N) = 0
             ADD 1 TO WS-COUNT
             MOVE WS-COUNT TO WS-INDEX(WS-N)
             MOVE WS-N TO WS-ORDER(WS-COUNT)
             MOVE BR-N-FIRST(WS-N) TO WS-CHILD
             PERFORM UNTIL WS-CHILD = 0
                 IF WS-INCLUDED(WS-CHILD) = 1
                     ADD 1 TO WS-TAIL
                     MOVE WS-CHILD TO WS-Q(WS-TAIL)
                 END-IF
                 MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
             END-PERFORM
             IF WS-KEEP-REDIRECT(WS-N) = 1
                 ADD 1 TO WS-TAIL
                 MOVE BR-N-REDIRECT(WS-N) TO WS-Q(WS-TAIL)
             END-IF
         END-IF
     END-PERFORM.

 PUT-NODE.
     MOVE WS-ORDER(WS-I) TO WS-N
     INITIALIZE WK-COMMAND-NODE-X
     MOVE BR-N-KIND(WS-N) TO WK-CX-FLAGS
     IF BR-N-COMMAND(WS-N) > 0
         ADD WK-NODE-EXECUTABLE TO WK-CX-FLAGS
     END-IF
     IF WS-KEEP-REDIRECT(WS-N) = 1
         ADD WK-NODE-HAS-REDIRECT TO WK-CX-FLAGS
         COMPUTE WK-CX-REDIRECT = WS-INDEX(BR-N-REDIRECT(WS-N)) - 1
     END-IF
     IF BR-N-SUGGEST(WS-N) > 0 AND BR-N-KIND(WS-N) = BR-ARGUMENT
         ADD WK-NODE-HAS-SUGGEST TO WK-CX-FLAGS
         MOVE WS-SUGGEST TO WK-CX-SUGGEST
         MOVE 20 TO WK-CX-SUGGEST-LENGTH
     END-IF
     IF WS-N > 1 AND BR-N-LEVEL(WS-N) > 0
         ADD WK-NODE-RESTRICTED TO WK-CX-FLAGS
     END-IF
     MOVE BR-N-FIRST(WS-N) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0
         IF WS-INCLUDED(WS-CHILD) = 1
             ADD 1 TO WK-CX-CHILD-COUNT
             COMPUTE WK-CX-CHILD(WK-CX-CHILD-COUNT) = WS-INDEX(WS-CHILD) - 1
         END-IF
         MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
     END-PERFORM
     IF BR-N-KIND(WS-N) > 0
         MOVE BR-N-NAME-LENGTH(WS-N) TO WK-CX-NAME-LENGTH
         MOVE BR-N-NAME(WS-N) TO WK-CX-NAME
     END-IF
     IF BR-N-KIND(WS-N) = BR-ARGUMENT
         MOVE BR-N-TYPE(WS-N) TO WK-CX-PARSER
         PERFORM PUT-PROPERTIES
     END-IF
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER WK-COMMAND-NODE-X.

*> The property bytes of the argument parsers the framework knows: a number range (flag bit 0 the
*> minimum, bit 1 the maximum, then the bounds) and the string kind.
 PUT-PROPERTIES.
     IF BR-N-TYPE(WS-N) = BR-P-STRING
         MOVE BR-N-STRING-KIND(WS-N) TO WK-CX-STRING-KIND
     END-IF
     IF BR-N-TYPE(WS-N) >= BR-P-FLOAT AND BR-N-TYPE(WS-N) <= BR-P-LONG
         COMPUTE WK-CX-RANGE-FLAGS = BR-N-HAS-MIN(WS-N) + 2 * BR-N-HAS-MAX(WS-N)
         EVALUATE BR-N-TYPE(WS-N)
             WHEN BR-P-INTEGER
                 MOVE BR-N-IMIN(WS-N) TO WK-CX-MIN-INT
                 MOVE BR-N-IMAX(WS-N) TO WK-CX-MAX-INT
             WHEN BR-P-LONG
                 MOVE BR-N-IMIN(WS-N) TO WK-CX-MIN-LONG
                 MOVE BR-N-IMAX(WS-N) TO WK-CX-MAX-LONG
             WHEN BR-P-FLOAT
                 MOVE BR-N-DMIN(WS-N) TO WK-CX-MIN-FLOAT
                 MOVE BR-N-DMAX(WS-N) TO WK-CX-MAX-FLOAT
             WHEN OTHER
                 MOVE BR-N-DMIN(WS-N) TO WK-CX-MIN-DOUBLE
                 MOVE BR-N-DMAX(WS-N) TO WK-CX-MAX-DOUBLE
         END-EVALUATE
     END-IF.
 END PROGRAM BR-TREE-BUILD.
