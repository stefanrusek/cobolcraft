*> Acceptance test of docs/protocol/35-worldgen-features-2 section 7 (corrections and additions to earlier documents): the three shapes and bounds of variety, the written forms of normalize, the bounds of the noise parameters, the legacy fromHashOf rule and the rule_based continuation that correct earlier documents.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-7.
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
     MOVE 3 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: an int is the range [3, 3]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 303 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 3 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: a list [1, 3] is accepted (the pack's form)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 103 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 2 TO WS-B
     MOVE 5 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: the object form is accepted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 205 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 3 TO WS-B
     MOVE 1 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: min above max fails" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 10301 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 3 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: a minimum of 0 is outside [1, 64]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 20003 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 65 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: a maximum of 65 is outside [1, 64]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 20165 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 64 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-VARIETY" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: variety: the int 64 is accepted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 10000 + WS-E * 100 + WS-F
     MOVE 6464 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "true" TO WS-TXT16
     CALL "F352-NORMALIZE-FORM" USING WS-TXT16 WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: normalize written as true gives 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "false" TO WS-TXT16
     CALL "F352-NORMALIZE-FORM" USING WS-TXT16 WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: normalize written as false gives 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "legacy" TO WS-TXT16
     CALL "F352-NORMALIZE-FORM" USING WS-TXT16 WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: normalize written as legacy gives 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "enabled" TO WS-TXT16
     CALL "F352-NORMALIZE-FORM" USING WS-TXT16 WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: normalize written as enabled gives -1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "disabled" TO WS-TXT16
     CALL "F352-NORMALIZE-FORM" USING WS-TXT16 WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: normalize written as disabled gives -1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -32 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: base_octave -32 is accepted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -33 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: base_octave -33 is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 33 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: base_octave 33 is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: octave_count 0 is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 33 TO WS-B
     MOVE 0 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: octave_count 33 is refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 3 TO WS-B
     MOVE 3 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: three modifiers for three octaves are accepted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 3 TO WS-B
     MOVE 2 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: two modifiers for three octaves are refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 32 TO WS-B
     MOVE 33 TO WS-C
     CALL "F352-NOISE-PARAMS-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: 33 modifiers are refused" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1261148513 TO WS-A
     MOVE 0 TO WS-S1
     CALL "F352-OCTAVE-SEED" USING WS-A WS-S1 WS-S2
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: fromHashOf with a legacy source is hashCode xor key, not the MD5 form (octave_0 xor 0 is the hash itself)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-S2
     MOVE 1261148513 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 0 TO WS-L2(1)
     MOVE 9 TO WS-L2(2)
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 7 TO WS-C
     CALL "F352-RULE-BASED" USING WS-A WS-LIST WS-LIST2 WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§7 Corrections and additions to earlier documents: rule_based scan continues after a null answer (correction of 23 section 7.4)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
