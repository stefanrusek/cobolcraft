*> Acceptance test of docs/protocol/35-worldgen-features-2 section 2 (the environment a predicate or provider sees): vertical anchors, the generation context of a world generation level (minimum y, height) and the void_air read outside the build height.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-2.
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
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor absolute 0 resolves to 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 10 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor above_bottom 10 at min y -64 resolves to -54" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE -54 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor above_bottom 0 resolves to -64" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE -64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor below_top 0 is the top block resolves to 319" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 319 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 10 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor below_top 10 resolves to 309" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 309 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 5 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     MOVE 63 TO WS-E
     CALL "F352-ANCHOR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: anchor relative_to_sea_level 5 (sea level 63) resolves to 68" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 68 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE 384 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     CALL "F352-GEN-CONTEXT" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: generation context of level (-64, 384) and generator (-64, 384) is (-64, 384)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E * 10000 + WS-F
     MOVE -639616 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 256 TO WS-B
     MOVE -64 TO WS-C
     MOVE 384 TO WS-D
     CALL "F352-GEN-CONTEXT" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: generation context of level (0, 256) and generator (-64, 384) is (0, 256)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E * 10000 + WS-F
     MOVE 256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE 384 TO WS-B
     MOVE -64 TO WS-C
     MOVE 256 TO WS-D
     CALL "F352-GEN-CONTEXT" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: generation context of level (-64, 384) and generator (-64, 256) is (-64, 256)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E * 10000 + WS-F
     MOVE -639744 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE 384 TO WS-B
     MOVE 0 TO WS-C
     MOVE 384 TO WS-D
     CALL "F352-GEN-CONTEXT" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: generation context of level (-64, 384) and generator (0, 384) is (0, 384)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E * 10000 + WS-F
     MOVE 384 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -65 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F352-READS-VOID" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: a read at y -65 gives void_air: 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F352-READS-VOID" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: a read at y -64 gives void_air: 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 319 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F352-READS-VOID" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: a read at y 319 gives void_air: 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 320 TO WS-A
     MOVE -64 TO WS-B
     MOVE 384 TO WS-C
     CALL "F352-READS-VOID" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§2 The environment a predicate or provider sees: a read at y 320 gives void_air: 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
