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
 01 B-NAME                 PIC X(64) BASED.
 LINKAGE SECTION.
 01 L-PARENT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X.
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PARENT L-KIND L-NAME L-NAME-LENGTH L-TYPE L-NODE L-CREATED.
     SET ADDRESS OF B-NAME TO ADDRESS OF L-NAME
     MOVE 0 TO L-NODE L-CREATED
     MOVE BR-N-FIRST(L-PARENT) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0 OR L-NODE > 0
         IF BR-N-NAME-LENGTH(WS-CHILD) = L-NAME-LENGTH
                 AND BR-N-NAME(WS-CHILD)(1:L-NAME-LENGTH) = B-NAME(1:L-NAME-LENGTH)
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
         MOVE B-NAME(1:L-NAME-LENGTH) TO BR-N-NAME(L-NODE)
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
*> flags: type, 0x04 executable, 0x08 redirect, 0x10 custom suggestions (the Identifier of BR-N-SUGGEST: 1 ask_server,
*> 2 available_sounds, 3 summonable_entities, 4 post_effects), 0x20 restricted (the node's own requirement fails for a
*> source with no permission, so level above 0); then the root index 0. Equal nodes share one index and one entry (57-client-closures-4
*> section 2.2): same kind and name, no command, a literal or an unbounded number argument of the same parser, and the same
*> children (the set of name and child pairs, each child compared in the same way); the first node met supplies the flags,
*> redirect and provider of the entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 16.
 01 WS-ROOT-INDEX          BINARY-LONG VALUE 0.
 01 WS-SUGGEST             PIC X(64).
 01 WS-SUGGEST-LENGTH      BINARY-LONG.
 01 WS-M                   BINARY-DOUBLE VALUE 2147483647.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-A1                  BINARY-DOUBLE.
 01 WS-A2                  BINARY-DOUBLE.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-C                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NK                  BINARY-LONG.
 01 WS-EQ                  BINARY-LONG.
 01 WS-BUCKET-INDEX        BINARY-LONG.
 01 WS-HASHES.
    05 WS-H1                BINARY-LONG OCCURS 4096 TIMES.
    05 WS-H2                BINARY-LONG OCCURS 4096 TIMES.
    05 WS-MERGEABLE         BINARY-LONG OCCURS 4096 TIMES.
    05 WS-KIDS              BINARY-LONG OCCURS 4096 TIMES.
    05 WS-CHAIN             BINARY-LONG OCCURS 4096 TIMES.
    05 WS-BUCKET            BINARY-LONG OCCURS 4099 TIMES.
 01 WS-COPY.
    05 WS-INCLUDED          BINARY-LONG OCCURS 4096 TIMES.
    05 WS-KEEP-REDIRECT     BINARY-LONG OCCURS 4096 TIMES.
    05 WS-INDEX             BINARY-LONG OCCURS 4096 TIMES.   *> wire index + 1, 0 = not numbered
    05 WS-ORDER             BINARY-LONG OCCURS 4096 TIMES.   *> node of wire index i - 1
 01 WS-STACK.
    05 WS-STACK-NODE        BINARY-LONG OCCURS 64 TIMES.
    05 WS-STACK-CHILD       BINARY-LONG OCCURS 64 TIMES.
 01 WS-QUEUE.
    05 WS-Q                 BINARY-LONG OCCURS 8192 TIMES.
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
     GO TO MAIN-LINE.

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

 HASH-NODES.
*>   A hash pair of every included node (children before parents: a child is created after its parent), for the equality of 2.2.
     PERFORM VARYING WS-N FROM BR-NODE-COUNT BY -1 UNTIL WS-N < 2
         IF WS-INCLUDED(WS-N) = 1
             MOVE 0 TO WS-MERGEABLE(WS-N)
             IF BR-N-COMMAND(WS-N) = 0 AND (BR-N-KIND(WS-N) = BR-LITERAL
                     OR (BR-N-KIND(WS-N) = BR-ARGUMENT AND BR-N-TYPE(WS-N) >= BR-P-FLOAT AND BR-N-TYPE(WS-N) <= BR-P-LONG
                         AND BR-N-HAS-MIN(WS-N) = 0 AND BR-N-HAS-MAX(WS-N) = 0))
                 MOVE 1 TO WS-MERGEABLE(WS-N)
             END-IF
             COMPUTE WS-A1 = BR-N-KIND(WS-N) * 31 + BR-N-TYPE(WS-N)
             COMPUTE WS-A2 = BR-N-KIND(WS-N) * 37 + BR-N-TYPE(WS-N) + 5
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > BR-N-NAME-LENGTH(WS-N)
                 COMPUTE WS-K = FUNCTION ORD(BR-N-NAME(WS-N)(WS-C:1))
                 COMPUTE WS-T = WS-A1 * 257 + WS-K
                 COMPUTE WS-A1 = FUNCTION MOD(WS-T, WS-M)
                 COMPUTE WS-T = WS-A2 * 263 + WS-K
                 COMPUTE WS-A2 = FUNCTION MOD(WS-T, WS-M)
             END-PERFORM
             MOVE 0 TO WS-S1 WS-S2 WS-KIDS(WS-N)
             MOVE BR-N-FIRST(WS-N) TO WS-CHILD
             PERFORM UNTIL WS-CHILD = 0
                 IF WS-INCLUDED(WS-CHILD) = 1
                     ADD 1 TO WS-KIDS(WS-N)
                     COMPUTE WS-T = WS-H1(WS-CHILD) * 7919 + 17
                     COMPUTE WS-S1 = FUNCTION MOD(WS-S1 + FUNCTION MOD(WS-T, WS-M), WS-M)
                     COMPUTE WS-T = WS-H2(WS-CHILD) * 7927 + 19
                     COMPUTE WS-S2 = FUNCTION MOD(WS-S2 + FUNCTION MOD(WS-T, WS-M), WS-M)
                 END-IF
                 MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
             END-PERFORM
             IF WS-MERGEABLE(WS-N) = 1
                 COMPUTE WS-T = WS-A1 * 65599 + WS-S1 + WS-KIDS(WS-N)
                 COMPUTE WS-H1(WS-N) = FUNCTION MOD(WS-T, WS-M)
                 COMPUTE WS-T = WS-A2 * 65587 + WS-S2 + WS-KIDS(WS-N) * 3
                 COMPUTE WS-H2(WS-N) = FUNCTION MOD(WS-T, WS-M)
             ELSE
*>               a node that cannot be equal to another makes its parents unique too
                 COMPUTE WS-H1(WS-N) = WS-N * 2 + 1000003
                 COMPUTE WS-H2(WS-N) = WS-N * 3 + 2000003
             END-IF
         END-IF
     END-PERFORM.

 FIND-EQUAL.
*>   The numbered node equal to WS-N (0 none): the same hash pair, kind, name, parser and number of children.
     MOVE 0 TO WS-EQ
     IF WS-MERGEABLE(WS-N) = 1
         COMPUTE WS-BUCKET-INDEX = FUNCTION MOD(WS-H1(WS-N), 4099) + 1
         MOVE WS-BUCKET(WS-BUCKET-INDEX) TO WS-NK
         PERFORM UNTIL WS-NK = 0 OR WS-EQ > 0
             IF WS-H1(WS-NK) = WS-H1(WS-N) AND WS-H2(WS-NK) = WS-H2(WS-N)
                     AND BR-N-KIND(WS-NK) = BR-N-KIND(WS-N) AND BR-N-TYPE(WS-NK) = BR-N-TYPE(WS-N)
                     AND BR-N-NAME-LENGTH(WS-NK) = BR-N-NAME-LENGTH(WS-N) AND WS-KIDS(WS-NK) = WS-KIDS(WS-N)
                     AND BR-N-NAME(WS-NK) = BR-N-NAME(WS-N)
                 MOVE WS-NK TO WS-EQ
             ELSE
                 MOVE WS-CHAIN(WS-NK) TO WS-NK
             END-IF
         END-PERFORM
     END-IF.

 NUMBER-NODES.
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE 1 TO WS-Q(1)
     MOVE 0 TO WS-COUNT
     PERFORM UNTIL WS-HEAD > WS-TAIL
         MOVE WS-Q(WS-HEAD) TO WS-N
         ADD 1 TO WS-HEAD
         IF WS-INDEX(WS-N) = 0
             PERFORM FIND-EQUAL
             IF WS-EQ > 0
                 MOVE WS-INDEX(WS-EQ) TO WS-INDEX(WS-N)
             ELSE
                 ADD 1 TO WS-COUNT
                 MOVE WS-COUNT TO WS-INDEX(WS-N)
                 MOVE WS-N TO WS-ORDER(WS-COUNT)
                 IF WS-MERGEABLE(WS-N) = 1
                     COMPUTE WS-BUCKET-INDEX = FUNCTION MOD(WS-H1(WS-N), 4099) + 1
                     MOVE WS-BUCKET(WS-BUCKET-INDEX) TO WS-CHAIN(WS-N)
                     MOVE WS-N TO WS-BUCKET(WS-BUCKET-INDEX)
                 END-IF
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
         EVALUATE BR-N-SUGGEST(WS-N)
             WHEN 2
                 MOVE "minecraft:available_sounds" TO WS-SUGGEST
                 MOVE 26 TO WS-SUGGEST-LENGTH
             WHEN 3
                 MOVE "minecraft:summonable_entities" TO WS-SUGGEST
                 MOVE 29 TO WS-SUGGEST-LENGTH
             WHEN 4
                 MOVE "minecraft:post_effects" TO WS-SUGGEST
                 MOVE 22 TO WS-SUGGEST-LENGTH
             WHEN OTHER
                 MOVE "minecraft:ask_server" TO WS-SUGGEST
                 MOVE 20 TO WS-SUGGEST-LENGTH
         END-EVALUATE
         MOVE WS-SUGGEST TO WK-CX-SUGGEST
         MOVE WS-SUGGEST-LENGTH TO WK-CX-SUGGEST-LENGTH
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
*>   The flags byte of an entity (1 single, 2 players only) and of a score holder (1 several), the minimum of a time and the registry of a resource parser (2.1).
     IF BR-N-TYPE(WS-N) = BR-P-ENTITY OR BR-N-TYPE(WS-N) = BR-P-SCORE-HOLDER
         MOVE BR-N-FLAGS(WS-N) TO WK-CX-FLAGS-BYTE
     END-IF
     IF BR-N-TYPE(WS-N) = BR-P-TIME
         MOVE BR-N-IMIN(WS-N) TO WK-CX-TIME-MIN
     END-IF
     IF BR-N-TYPE(WS-N) >= BR-P-RES-OR-TAG AND BR-N-TYPE(WS-N) <= BR-P-RES-SELECTOR AND BR-N-REG-LENGTH(WS-N) > 0
         MOVE BR-N-REG-LENGTH(WS-N) TO WK-CX-REGISTRY-LENGTH
         MOVE BR-N-REG(WS-N) TO WK-CX-REGISTRY
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

 MAIN-LINE.
     INITIALIZE WS-COPY
     MOVE 1 TO WS-INCLUDED(1)
     PERFORM COPY-TREE
     INITIALIZE WS-HASHES
     PERFORM HASH-NODES
     PERFORM NUMBER-NODES
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         PERFORM PUT-NODE
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ROOT-INDEX.
 END PROGRAM BR-TREE-BUILD.
