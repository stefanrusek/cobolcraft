*> Acceptance test of docs/protocol/35-worldgen-features-1 section 4 (the world-generation level): the 3 x 3 write window, the read availability by distance (8 and 9), the build height test, the heightmap names, ordinals and block tests, and the update rule of section 4.2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-HM                  PIC X(32).
 01 WS-TEXT                PIC X(60).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     CALL "F351-WRITE-ZONE" USING WS-A WS-B WS-C WS-F WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: write window of radius 1 around (0, 0): chunk (0, 0) gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE -1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     CALL "F351-WRITE-ZONE" USING WS-A WS-B WS-C WS-F WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: write window of radius 1 around (0, 0): chunk (1, -1) gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     CALL "F351-WRITE-ZONE" USING WS-A WS-B WS-C WS-F WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: write window of radius 1 around (0, 0): chunk (-1, 1) gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     CALL "F351-WRITE-ZONE" USING WS-A WS-B WS-C WS-F WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: write window of radius 1 around (0, 0): chunk (2, 0) gives 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE -2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     CALL "F351-WRITE-ZONE" USING WS-A WS-B WS-C WS-F WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: write window of radius 1 around (0, 0): chunk (0, -2) gives 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F351-READ-AVAILABLE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: chunk at distance 0: available 1, hasChunk 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-A
     CALL "F351-READ-AVAILABLE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: chunk at distance 8: available 1, hasChunk 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     CALL "F351-READ-AVAILABLE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: chunk at distance 9: available 0, hasChunk 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 10 + WS-C
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -65 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F351-Y-OUTSIDE" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: y -65 outside the build height (-64, 384): 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F351-Y-OUTSIDE" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: y -64 outside the build height (-64, 384): 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 319 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F351-Y-OUTSIDE" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: y 319 outside the build height (-64, 384): 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 320 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F351-Y-OUTSIDE" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: y 320 outside the build height (-64, 384): 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "WORLD_SURFACE_WG" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap WORLD_SURFACE_WG has ordinal 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "WORLD_SURFACE" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap WORLD_SURFACE has ordinal 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "OCEAN_FLOOR_WG" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap OCEAN_FLOOR_WG has ordinal 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "OCEAN_FLOOR" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap OCEAN_FLOOR has ordinal 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "MOTION_BLOCKING" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap MOTION_BLOCKING has ordinal 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "MOTION_BLOCKING_NO_LEAVES" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: heightmap MOTION_BLOCKING_NO_LEAVES has ordinal 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "SURFACE" TO WS-HM
     CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: an unknown heightmap name has no ordinal" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: WORLD_SURFACE counts any non-air block" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: WORLD_SURFACE does not count air" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: OCEAN_FLOOR counts a motion blocking block" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: OCEAN_FLOOR does not count a fluid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: MOTION_BLOCKING counts a fluid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: MOTION_BLOCKING counts a blocking block" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: MOTION_BLOCKING_NO_LEAVES does not count leaves (tag one only)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: MOTION_BLOCKING_NO_LEAVES counts the no-leaves tag" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-F
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "F351-HEIGHTMAP-PASSES" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: MOTION_BLOCKING_NO_LEAVES counts a fluid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 70 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: a passing block at the first free y raises it" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 71 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 69 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: a passing block below the first free y is ignored" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 68 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: a change at first - 2 is ignored" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 69 TO WS-B
     MOVE 0 TO WS-C
     MOVE 65 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: removing the top block rescans" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 65 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 60 TO WS-B
     MOVE 0 TO WS-C
     MOVE 65 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: removing a block far below is ignored" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 70 TO WS-B
     MOVE 0 TO WS-C
     MOVE 65 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: a failing block at the first free y changes nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-A
     MOVE 75 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: a passing block above raises to y + 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 76 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO WS-A
     MOVE 69 TO WS-B
     MOVE 0 TO WS-C
     MOVE 64 TO WS-D
     CALL "F351-HEIGHTMAP-UPDATE" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§4 The world-generation level: removing the top block of a column with none below gives min y" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
