*> Test of the number providers that 26 section 9 gives in closed form and loot-provider.cob adds to the first set (test_loot_providers): int
*> pow (powExact: 0^0 and an overflow are errors, so 0), float avg (sum / count in float), mod (the float remainder, NaN for a zero divisor),
*> pow (NaN for 0^0), sin and cos (the 65536-entry table of 9.3: SIN[i] = (float) sin(i / 10430.378350470453), the index (long)(x * 10430.378350470453)
*> and 65535, cos shifted by 16384) and length (sqrt of the sum of squares). A NaN result is 0 through getFloat (9.1). The expected values come from
*> scratchpad/loot2/ref_math.py (Python with binary32 rounding, the table built the same way), not from the COBOL code. Floats are shown in millionths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-PROVIDERS-MATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY LOOTCTX.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "F|f_avg|0|0|-1|2500000".
    05 FILLER PIC X(60) VALUE "F|f_mod|0|0|-1|1500000".
    05 FILLER PIC X(60) VALUE "F|f_mod_neg|0|0|-1|-1500000".
    05 FILLER PIC X(60) VALUE "F|f_mod0|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_pow|0|0|-1|8000000".
    05 FILLER PIC X(60) VALUE "F|f_pow_frac|0|0|-1|1414214".
    05 FILLER PIC X(60) VALUE "F|f_pow00|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_pow_negfrac|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_pow_inf|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_pow_neg_int|0|0|-1|-8000000".
    05 FILLER PIC X(60) VALUE "F|f_avg_empty|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_sin|0|0|-1|841451".
    05 FILLER PIC X(60) VALUE "F|f_sin_neg|0|0|-1|-841451".
    05 FILLER PIC X(60) VALUE "F|f_sin_big|0|0|-1|-506435".
    05 FILLER PIC X(60) VALUE "F|f_cos|0|0|-1|540333".
    05 FILLER PIC X(60) VALUE "F|f_cos_zero|0|0|-1|1000000".
    05 FILLER PIC X(60) VALUE "F|f_cos_neg|0|0|-1|-801089".
    05 FILLER PIC X(60) VALUE "F|f_length|0|0|-1|5000000".
    05 FILLER PIC X(60) VALUE "F|f_length3|0|0|-1|3000000".
    05 FILLER PIC X(60) VALUE "F|f_length_frac|0|0|-1|1581139".
    05 FILLER PIC X(60) VALUE "I|i_pow|0|0|-1|1024".
    05 FILLER PIC X(60) VALUE "I|i_pow_neg_base|0|0|-1|-8".
    05 FILLER PIC X(60) VALUE "I|i_pow_zero_exp|0|0|-1|1".
    05 FILLER PIC X(60) VALUE "I|i_pow_big|0|0|-1|1073741824".
    05 FILLER PIC X(60) VALUE "I|i_pow_overflow|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_pow00|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_pow_m1_odd|0|0|-1|-1".
    05 FILLER PIC X(60) VALUE "I|i_pow_m1_even|0|0|-1|1".
    05 FILLER PIC X(60) VALUE "I|i_pow_neg_exp|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_pow_zero_base|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_pow_one|0|0|-1|1".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(60) OCCURS 31 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                PIC X.
 01 WS-NAME                PIC X(40).
 01 WS-SEED                PIC X(12).
 01 WS-KILLER              PIC X(2).
 01 WS-ENCH                PIC X(4).
 01 WS-EXPECT              PIC X(12).
 01 WS-KEY                 PIC X(112).
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-MILLIONTHS          BINARY-DOUBLE.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EDIT                PIC -(12)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot provider the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         MOVE SPACES TO WS-NAME WS-SEED WS-KILLER WS-ENCH WS-EXPECT
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-KIND WS-NAME WS-SEED WS-KILLER WS-ENCH WS-EXPECT
         INITIALIZE LOOT-CONTEXT
         COMPUTE LC-SEED = FUNCTION NUMVAL(WS-SEED)
         COMPUTE LC-KILLER = FUNCTION NUMVAL(WS-KILLER)
         IF FUNCTION NUMVAL(WS-ENCH) >= 0
             MOVE 1 TO LC-ENCH-SET
             COMPUTE LC-ENCH-LEVEL = FUNCTION NUMVAL(WS-ENCH)
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "test:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         IF WS-KIND = "I"
             CALL "LOOT-INT-OF" USING WS-KEY LOOT-CONTEXT WS-INT WS-FOUND
             MOVE WS-INT TO WS-MILLIONTHS
         ELSE
             CALL "LOOT-FLOAT-OF" USING WS-KEY LOOT-CONTEXT WS-FLOAT WS-FOUND
             COMPUTE WS-MILLIONTHS ROUNDED = WS-FLOAT * 1000000
         END-IF
         MOVE WS-MILLIONTHS TO WS-EDIT
         MOVE SPACES TO TL-OBSERVED
         MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
         MOVE SPACES TO TL-CASE
         STRING "test loot provider " WS-KIND " " FUNCTION TRIM(WS-NAME) " seed " FUNCTION TRIM(WS-SEED)
             " killer " FUNCTION TRIM(WS-KILLER) " level " FUNCTION TRIM(WS-ENCH) DELIMITED BY SIZE INTO TL-CASE
         MOVE FUNCTION TRIM(WS-EXPECT) TO TL-EXPECTED
         PERFORM CHECK
     END-PERFORM
     MOVE "test loot provider a missing int provider is not found" TO TL-CASE
     MOVE "test:no_such" TO WS-KEY
     CALL "LOOT-INT-OF" USING WS-KEY LOOT-CONTEXT WS-INT WS-FOUND
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "test loot provider a missing float provider is not found" TO TL-CASE
     CALL "LOOT-FLOAT-OF" USING WS-KEY LOOT-CONTEXT WS-FLOAT WS-FOUND
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "test loot provider an int provider without a namespace is minecraft:" TO TL-CASE
     MOVE "i_const" TO WS-KEY
     CALL "LOOT-INT-OF" USING WS-KEY LOOT-CONTEXT WS-INT WS-FOUND
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOOT-PROVIDERS-MATH.
 COPY CORETEST.
