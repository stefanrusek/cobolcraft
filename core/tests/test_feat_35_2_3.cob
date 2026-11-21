*> Acceptance test of docs/protocol/35-worldgen-features-2 section 3 (block predicates): the offset range of 16, the tag key form, the validity and visiting order of volume_match (the 50 cells of the desert well box), and the short-circuit rules and empty lists of any_of and all_of. The state reads themselves belong to the level binding.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-3.
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
 01 WS-DRAW                BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIST2.
    05 WS-L2               BINARY-LONG OCCURS 64 TIMES.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CH                  FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-S3                  BINARY-DOUBLE.
 01 WS-SEED2               BINARY-DOUBLE UNSIGNED.
 01 WS-EDIT                PIC -(19)9.
 01 WS-TEXT                PIC X(64).
 01 WS-NAME32              PIC X(32).
 01 WS-TXT16               PIC X(16).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 16 TO WS-A
     MOVE -16 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-OFFSET-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: offset [16, -16, 0] in range: 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-OFFSET-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: offset [17, 0, 0] in range: 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE -17 TO WS-C
     CALL "F352-OFFSET-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: offset [0, 0, -17] in range: 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 16 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-OFFSET-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: offset [0, 16, 0] in range: 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:air" TO WS-TEXT
     CALL "F352-TAG-KEY-OK" USING WS-TEXT WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: tag key minecraft:air accepted: 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "#minecraft:air" TO WS-TEXT
     CALL "F352-TAG-KEY-OK" USING WS-TEXT WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: tag key #minecraft:air accepted: 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "F352-VOLUME-VALID" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match min above max: status 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-G
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -17 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "F352-VOLUME-VALID" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match min out of range: status 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-G
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     CALL "F352-VOLUME-VALID" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match the desert well box: status 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-G
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 17 TO WS-F
     CALL "F352-VOLUME-VALID" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match max out of range: status 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-G
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 0 TO WS-G
     CALL "F352-VOLUME-CELL" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match cell first is (-2, -2, -2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-H + 10) * 10000 + (WS-I + 10) * 100 + (WS-J + 10)
     MOVE 80808 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 1 TO WS-G
     CALL "F352-VOLUME-CELL" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match cell second (y is innermost) is (-2, -1, -2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-H + 10) * 10000 + (WS-I + 10) * 100 + (WS-J + 10)
     MOVE 80908 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 2 TO WS-G
     CALL "F352-VOLUME-CELL" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match cell third (z is the middle loop) is (-2, -2, -1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-H + 10) * 10000 + (WS-I + 10) * 100 + (WS-J + 10)
     MOVE 80809 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 49 TO WS-G
     CALL "F352-VOLUME-CELL" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: volume_match cell last is (2, -1, 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-H + 10) * 10000 + (WS-I + 10) * 100 + (WS-J + 10)
     MOVE 120912 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-A
     MOVE -2 TO WS-B
     MOVE -2 TO WS-C
     MOVE 2 TO WS-D
     MOVE -1 TO WS-E
     MOVE 2 TO WS-F
     MOVE 0 TO WS-G
     CALL "F352-VOLUME-CELL" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-K
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: the desert well box has 50 cells" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-K
     MOVE 50 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F352-ANY-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: any_of of nothing is false (evaluated 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 0 TO WS-L(2)
     MOVE 2 TO WS-A
     CALL "F352-ANY-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: any_of stops at the first true child (evaluated 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 2 TO WS-A
     CALL "F352-ANY-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: any_of evaluates up to the true child (evaluated 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 21 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F352-ALL-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: all_of of nothing is true (evaluated 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 0 TO WS-L(2)
     MOVE 1 TO WS-L(3)
     MOVE 3 TO WS-A
     CALL "F352-ALL-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: all_of stops at the first false child (evaluated 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 20 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 2 TO WS-A
     CALL "F352-ALL-OF" USING WS-A WS-LIST WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§3 Block predicates: all_of of true children is true (evaluated 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 21 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
