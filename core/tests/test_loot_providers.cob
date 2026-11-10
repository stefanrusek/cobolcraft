*> Test of the loot number providers (core/src/loot-provider.cob; docs/protocol/26-loot-and-predicates.md sections 8.1 and 9, 13.2 T15 to
*> T17): the constant, uniform, binomial, arithmetic, conditional, dispatcher and weighted forms of the int family, the float
*> family and the level based values, read from the named providers of core/tests/fixtures/loot (the registries context_int_provider
*> and context_float_provider, loaded by LOOT-LOAD) and evaluated through LOOT-INT-OF and LOOT-FLOAT-OF. A seed in a case selects the Java
*> LCG of 26 section 4 (the expected values come from an independent Python implementation of 10 section 2.6 and of the formulas
*> of 9.2 and 9.3); a case without a seed draws nothing. Floats are shown in millionths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-PROVIDERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY LOOTCTX.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "I|i_const|0|0|-1|5".
    05 FILLER PIC X(60) VALUE "I|i_obj_const|0|0|-1|-3".
    05 FILLER PIC X(60) VALUE "I|i_uniform|7|0|-1|7".
    05 FILLER PIC X(60) VALUE "I|i_uniform_eq|7|0|-1|4".
    05 FILLER PIC X(60) VALUE "I|i_binomial|7|0|-1|2".
    05 FILLER PIC X(60) VALUE "I|i_add|0|0|-1|6".
    05 FILLER PIC X(60) VALUE "I|i_sub|0|0|-1|6".
    05 FILLER PIC X(60) VALUE "I|i_mul|0|0|-1|24".
    05 FILLER PIC X(60) VALUE "I|i_div|0|0|-1|3".
    05 FILLER PIC X(60) VALUE "I|i_floor_div|0|0|-1|-4".
    05 FILLER PIC X(60) VALUE "I|i_mod|0|0|-1|-1".
    05 FILLER PIC X(60) VALUE "I|i_floor_mod|0|0|-1|1".
    05 FILLER PIC X(60) VALUE "I|i_div0|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_min|0|0|-1|2".
    05 FILLER PIC X(60) VALUE "I|i_max|0|0|-1|9".
    05 FILLER PIC X(60) VALUE "I|i_negate|0|0|-1|-5".
    05 FILLER PIC X(60) VALUE "I|i_abs|0|0|-1|8".
    05 FILLER PIC X(60) VALUE "I|i_avg|0|0|-1|2".
    05 FILLER PIC X(60) VALUE "I|i_cond|0|0|-1|1".
    05 FILLER PIC X(60) VALUE "I|i_cond|0|1|-1|7".
    05 FILLER PIC X(60) VALUE "I|i_cond_default|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_cond_default|0|1|-1|7".
    05 FILLER PIC X(60) VALUE "I|i_from_float|0|0|-1|2".
    05 FILLER PIC X(60) VALUE "I|i_weighted|7|0|-1|2".
    05 FILLER PIC X(60) VALUE "I|i_dispatch|0|1|-1|11".
    05 FILLER PIC X(60) VALUE "I|i_dispatch|0|0|-1|22".
    05 FILLER PIC X(60) VALUE "I|i_ref_add|0|0|-1|6".
    05 FILLER PIC X(60) VALUE "I|i_unsupported|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_overflow|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_overflow_add|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_neg_uniform|7|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_const|0|0|-1|500000".
    05 FILLER PIC X(60) VALUE "F|f_obj_const|0|0|-1|1500000".
    05 FILLER PIC X(60) VALUE "F|f_uniform|7|0|-1|1961398".
    05 FILLER PIC X(60) VALUE "F|f_uniform_eq|7|0|-1|2000000".
    05 FILLER PIC X(60) VALUE "F|f_add|0|0|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_sub|0|0|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_mul|0|0|-1|1500000".
    05 FILLER PIC X(60) VALUE "F|f_div|0|0|-1|250000".
    05 FILLER PIC X(60) VALUE "F|f_div0|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_min|0|0|-1|250000".
    05 FILLER PIC X(60) VALUE "F|f_max|0|0|-1|500000".
    05 FILLER PIC X(60) VALUE "F|f_negate|0|0|-1|-500000".
    05 FILLER PIC X(60) VALUE "F|f_abs|0|0|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_cond|0|0|-1|250000".
    05 FILLER PIC X(60) VALUE "F|f_cond|0|1|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_from_int|0|0|-1|3000000".
    05 FILLER PIC X(60) VALUE "F|f_lin|0|0|3|2000000".
    05 FILLER PIC X(60) VALUE "F|f_lin|0|0|-1|500000".
    05 FILLER PIC X(60) VALUE "F|f_lookup|0|0|2|2000000".
    05 FILLER PIC X(60) VALUE "F|f_lookup|0|0|5|26000000".
    05 FILLER PIC X(60) VALUE "F|f_const_level|0|0|1|2500000".
    05 FILLER PIC X(60) VALUE "F|f_clamped|0|0|3|5000000".
    05 FILLER PIC X(60) VALUE "F|f_fraction|0|0|3|333333".
    05 FILLER PIC X(60) VALUE "F|f_fraction0|0|0|3|0".
    05 FILLER PIC X(60) VALUE "F|f_exponent|0|0|3|8000000".
    05 FILLER PIC X(60) VALUE "F|f_floor|0|0|-1|-3000000".
    05 FILLER PIC X(60) VALUE "F|f_ceil|0|0|-1|-2000000".
    05 FILLER PIC X(60) VALUE "F|f_round|0|0|-1|-2000000".
    05 FILLER PIC X(60) VALUE "F|f_trunc|0|0|-1|-2000000".
    05 FILLER PIC X(60) VALUE "F|f_sqrt|0|0|-1|4000000".
    05 FILLER PIC X(60) VALUE "F|f_weighted|7|0|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_unsupported|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_avg_empty|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_ref_missing|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_weighted_empty|7|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_weighted_empty|7|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_ref_missing|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "I|i_bare_kind|0|0|-1|3".
    05 FILLER PIC X(60) VALUE "I|i_ref_bare|0|0|-1|0".
    05 FILLER PIC X(60) VALUE "F|f_ref_ok|0|0|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_dispatch|0|1|-1|750000".
    05 FILLER PIC X(60) VALUE "F|f_dispatch|0|0|-1|125000".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(60) OCCURS 73 TIMES.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 73
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
 END PROGRAM TEST-LOOT-PROVIDERS.
 COPY CORETEST.
