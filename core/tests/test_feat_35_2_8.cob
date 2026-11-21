*> Acceptance test of docs/protocol/35-worldgen-features-2 section 8 (ruletest helpers): the registration order of the 10 RuleTest types and the 3 PosRuleTest types.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-8.
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
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 0 is all_of" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "all_of" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 1 is always_true" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "always_true" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 2 is any_of" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "any_of" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 3 is block_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "block_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 4 is blockstate_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "blockstate_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 5 is not" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "not" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 6 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 6 is tag_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "tag_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 7 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 7 is height_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "height_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 8 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 8 is random_block_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "random_block_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 9 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType id 9 is random_blockstate_match" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "random_blockstate_match" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: PosRuleTestType id 0 is always_true" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "always_true" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: PosRuleTestType id 1 is linear_pos" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "linear_pos" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 2 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: PosRuleTestType id 2 is axis_aligned_linear_pos" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NAME32) TO TL-OBSERVED
     MOVE "axis_aligned_linear_pos" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 10 TO WS-B
     CALL "F352-RULETEST-NAME" USING WS-A WS-B WS-NAME32
     MOVE 0 TO WS-C
     IF WS-NAME32 = SPACES
         MOVE 1 TO WS-C
     END-IF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§8 RuleTest helpers: RuleTestType has no id 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
