*> Acceptance test of docs/protocol/35-worldgen-features-3 section 2 (treefeature): the room and clipping checks of doPlace, the free height scan, the result rule of place, the position hash, the leaf distance relaxation and the pass directions of the shape update.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 64 TO WS-A
     MOVE 64 TO WS-B
     MOVE 6 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: a tree of height 6 at y 64 has room" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE -64 TO WS-B
     MOVE 6 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: a tree at the bottom y has no room (min y < level min y + 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 310 TO WS-A
     MOVE 310 TO WS-B
     MOVE 9 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: 310 + 9 + 1 = 320 is the limit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 310 TO WS-A
     MOVE 310 TO WS-B
     MOVE 10 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: 310 + 10 + 1 = 321 is over" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO WS-A
     MOVE 70 TO WS-B
     MOVE 250 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: the root origin above counts for the top (70 + 250 + 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO WS-A
     MOVE -70 TO WS-B
     MOVE 6 TO WS-C
     MOVE -64 TO WS-D
     MOVE 319 TO WS-E
     CALL "F353-ROOM-OK" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "acceptance US12 35-3§2 TreeFeature: the root origin below counts for the bottom (-70)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     MOVE -1 TO WS-C
     CALL "F353-CLIP-OK" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: clipped with no minimum is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     MOVE 3 TO WS-C
     CALL "F353-CLIP-OK" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: clipped at the minimum is allowed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     MOVE 4 TO WS-C
     CALL "F353-CLIP-OK" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: clipped below the minimum is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     MOVE -1 TO WS-C
     CALL "F353-CLIP-OK" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: a free tree is allowed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 3 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: an obstruction at (0, 3, 0) gives 3 - 2 = 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 1 TO WS-H
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: an obstruction at (1, 0, 0) is outside the lower layer (size 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 1 TO WS-H
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: an obstruction at (1, 1, 0) is inside the upper layer (size 1): -1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 2 TO WS-H
     MOVE 2 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: an obstruction at (2, 2, 0) is out of reach" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 6 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: y = H + 1 is scanned: 6 - 2 = 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 7 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: y = H + 2 is not scanned" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 2 TO WS-I
     MOVE 0 TO WS-J
     MOVE 1 TO WS-K
     MOVE 1 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: a vine is ignored when ignore_vines is true" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 2 TO WS-I
     MOVE 0 TO WS-J
     MOVE 1 TO WS-K
     MOVE 0 TO WS-L
     CALL "F353-MAX-FREE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K WS-L WS-M
     MOVE "acceptance US12 35-3§2 TreeFeature: a vine blocks when ignore_vines is false" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-M
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "F353-TREE-RESULT" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: a tree with 0 logs and 0 foliage positions gives 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "F353-TREE-RESULT" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: a tree with 1 logs and 0 foliage positions gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "F353-TREE-RESULT" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: a tree with 0 logs and 1 foliage positions gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 3 TO WS-C
     CALL "F353-POS-HASH" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: the position hash of (1, 2, 3) is 2946" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 2946 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-A
     MOVE -7 TO WS-B
     MOVE -9 TO WS-C
     CALL "F353-POS-HASH" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: the position hash of (-5, -7, -9) is -8871" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE -8871 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2147483647 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "F353-POS-HASH" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: the position hash of (2147483647, 1, 0) is -2147483618" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE -2147483618 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "F353-POS-HASH" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: the position hash of (0, 0, 0) is 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     MOVE 0 TO WS-B
     CALL "F353-LEAF-RELAX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: a fresh leaf next to a log goes to layer 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 10 + WS-D
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 3 TO WS-B
     CALL "F353-LEAF-RELAX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: a neighbour that prevents decay goes to layer 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 10 + WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     MOVE 6 TO WS-B
     CALL "F353-LEAF-RELAX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: layer 7 is not enqueued" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 10 + WS-D
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-A
     MOVE 2 TO WS-B
     CALL "F353-LEAF-RELAX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: a neighbour with no distance is skipped" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 10 + WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 5 TO WS-B
     CALL "F353-LEAF-RELAX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§2 TreeFeature: a foreign leaf keeps its own smaller distance" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 10 + WS-D
     MOVE 21 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F353-PASS-DIRECTIONS" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: shape update pass 1 reports directions 2 and 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 23 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F353-PASS-DIRECTIONS" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: shape update pass 2 reports directions 0 and 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F353-PASS-DIRECTIONS" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§2 TreeFeature: shape update pass 3 reports directions 4 and 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 45 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
