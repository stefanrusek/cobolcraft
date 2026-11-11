*> Acceptance test of docs/protocol/35-worldgen-features-3 section 3 (feature sizes): getSizeAtHeight of two_layers_feature_size and three_layers_feature_size at the layer boundaries.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-3.
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
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 10 TO WS-G
     MOVE 0 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: two layers: the lower size below the limit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 10 TO WS-G
     MOVE 1 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: two layers: the upper size from the limit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     MOVE 9 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 9 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: two layers ignore the upper limit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 0 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers: the lower size below the limit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 5 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers: the middle size between" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 8 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers: y = H - upper_limit - 1 is still middle" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 9 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers: y = H - upper_limit is upper" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 10 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers: the top is upper" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 10 TO WS-G
     MOVE 0 TO WS-H
     CALL "F353-SIZE-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I
     MOVE "acceptance US12 35-3§3 Feature sizes: three layers with limits 0: the middle size at y 0 (the upper size starts at y = H)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-I
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
