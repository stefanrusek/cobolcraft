*> The number providers of the loot engine (T0436; docs/protocol/26-loot-and-predicates.md sections 8.1 and 9). A provider is a JSON
*> node (slot, node) of LOOT-DOCS: a bare number (a constant), a string (an entry of the data registry context_int_provider or
*> context_float_provider: a reference) or an object with a "type". Errors (division by zero, int overflow, a non-finite float, a
*> type this engine does not evaluate) set LW-ERR and the value is 0, which is what getInt and getFloat return (9.1).
*> Evaluated types. Int: constant, uniform, binomial, weighted_list, conditional, number_dispatcher, abs, negate, avg, add, mul,
*> min, max, sub, div, floor_div, mod, floor_mod, pow, from_float. Float: constant, uniform, weighted_list, conditional,
*> number_dispatcher, abs, negate, avg, add, mul, min, max, sub, div, mod, pow, ceil, floor, round, truncate, sqrt, length, sin, cos (the
*> table of 9.3), from_int, enchantment_level.
*> Level based values: a number, linear, lookup, exponent, clamped, fraction, levels_squared. Not evaluated (value 0 with LW-ERR set):
*> int environment_attribute, storage, score; float environment_attribute, storage (they need the scoreboard, command storage or
*> environment attributes, which the core does not have yet: BLOCKED on those systems).
*> Assumption: a weighted_list always draws (one nextInt(total weight)), even for one element; 9.2 does not say otherwise.
*> A float is rounded to binary32 after each operation (Java's float); the arithmetic runs in the shim's IEEE routines (cc_f64_*).
*> Entry points:
*>   LOOT-INT-EVAL USING slot, node, value out (BINARY-LONG)            getIntUnsafe: LW-ERR is set on an error
*>   LOOT-INT-GET USING slot, node, value out                           getInt: 0 on an error, LW-ERR as before
*>   LOOT-FLOAT-EVAL USING slot, node, value out (FLOAT-LONG), LOOT-FLOAT-GET likewise (getFloat)
*>   LOOT-LEVEL-EVAL USING slot, node, level (BINARY-LONG), value out (FLOAT-LONG)   LevelBasedValue (8.1)
*>   LOOT-INT-OF USING name (PIC X(112)), LOOT-CONTEXT, value out, found out    a named int provider of the data registry
*>   LOOT-FLOAT-OF USING name, LOOT-CONTEXT, value out (FLOAT-LONG), found out  a named float provider
*>   LOOT-ENTER USING LOOT-CONTEXT, sequence key (PIC X(112), spaces: the level's own random)   starts a roll or an evaluation

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENTER.
*> USING LOOT-CONTEXT, sequence key: copies the context into LOOT-WORK, clears the roll state and selects the random source: the
*> Java LCG when the context has an explicit seed (section 4 step 2), else the named sequence (step 4; no id: the level's random,
*> kept as the sequence "level").
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-LEVEL-KEY           PIC X(112) VALUE "level".
 LINKAGE SECTION.
 COPY LOOTCTX.
 01 L-SEQUENCE             PIC X(112).
 PROCEDURE DIVISION USING LOOT-CONTEXT L-SEQUENCE.
     MOVE LOOT-CONTEXT TO LW-CTX
     ADD 1 TO LDS-SERIAL
     MOVE 0 TO LW-ERR LW-VIS-COUNT LW-CHAIN-COUNT LW-OUT-COUNT
     EVALUATE TRUE
         WHEN LW-C-SEED NOT = 0
             CALL "LOOT-RNG-SEED-LCG" USING LW-C-SEED
         WHEN L-SEQUENCE NOT = SPACES
             CALL "LOOT-RNG-SEED-SEQUENCE" USING L-SEQUENCE LW-C-WORLD-SEED
         WHEN OTHER
             CALL "LOOT-RNG-SEED-SEQUENCE" USING WS-LEVEL-KEY LW-C-WORLD-SEED
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-ENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-INT-FIT.
*> USING accumulator (BINARY-DOUBLE), value out (BINARY-LONG): the accumulator as an int; outside the int range it is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 LINKAGE SECTION.
 01 L-ACC                  BINARY-DOUBLE.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ACC L-VALUE.
     IF L-ACC > 2147483647 OR L-ACC < -2147483648
         MOVE 1 TO LW-ERR
         MOVE 0 TO L-VALUE
     ELSE
         MOVE L-ACC TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM LOOT-INT-FIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-F32.
*> USING value (FLOAT-LONG, in and out): rounded to the nearest binary32; not finite (beyond the float range) is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-ROUNDED             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-VALUE BY REFERENCE WS-ROUNDED
     MOVE WS-ROUNDED TO L-VALUE
     GOBACK.
 END PROGRAM LOOT-F32.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-INT-EVAL IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(48) VALUE "context_int_provider".
 01 WS-N-INPUTS            PIC X(32) VALUE "inputs".
 01 WS-N-INPUT             PIC X(32) VALUE "input".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-N-N                 PIC X(32) VALUE "n".
 01 WS-N-P                 PIC X(32) VALUE "p".
 01 WS-N-LEFT              PIC X(32) VALUE "left".
 01 WS-N-RIGHT             PIC X(32) VALUE "right".
 01 WS-N-DIST              PIC X(32) VALUE "distribution".
 01 WS-N-DATA              PIC X(32) VALUE "data".
 01 WS-N-WEIGHT            PIC X(32) VALUE "weight".
 01 WS-N-CONDITION         PIC X(32) VALUE "condition".
 01 WS-N-TRUE              PIC X(32) VALUE "on_true".
 01 WS-N-FALSE             PIC X(32) VALUE "on_false".
 01 WS-N-CASES             PIC X(32) VALUE "cases".
 01 WS-N-DEFAULT           PIC X(32) VALUE "default".
 01 WS-N-BASE              PIC X(32) VALUE "base".
 01 WS-N-EXPONENT          PIC X(32) VALUE "exponent".
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OTHER               BINARY-LONG.
 01 LS-ACC                 BINARY-DOUBLE.
 01 LS-COUNT               BINARY-LONG.
 01 LS-TERM                BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-TOTAL               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-F                   FLOAT-LONG.
 01 LS-G                   FLOAT-LONG.
 01 LS-WEIGHT              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE.
     MOVE 0 TO L-VALUE
     MOVE L-SLOT TO LS-SLOT
     MOVE L-NODE TO LS-NODE
     IF LS-NODE = 0
         GOBACK
     END-IF
     EVALUATE LDS-JN-TYPE(LS-SLOT, LS-NODE)
         WHEN JT-NUMBER
             MOVE LDS-JN-NUM(LS-SLOT, LS-NODE) TO LS-F
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE LS-F BY REFERENCE L-VALUE
             GOBACK
         WHEN JT-STRING
             CALL "LOOT-HOLDER" USING WS-REGISTRY LS-SLOT LS-NODE
             IF LS-NODE = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL "LOOT-INT-EVAL" USING LS-SLOT LS-NODE L-VALUE
             END-IF
             GOBACK
         WHEN JT-OBJECT
             CONTINUE
         WHEN OTHER
             MOVE 1 TO LW-ERR
             GOBACK
     END-EVALUATE
     CALL "LOOT-J-KIND" USING LS-SLOT LS-NODE LS-KIND
     EVALUATE LS-KIND
         WHEN "constant"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER L-VALUE
         WHEN "uniform"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-MIN LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-MAX LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             MOVE LS-A TO L-VALUE
             IF LS-A < LS-B
                 COMPUTE LS-TOTAL = LS-B - LS-A + 1
                 CALL "LOOT-RNG-INT" USING LS-TOTAL LS-DRAW
                 COMPUTE L-VALUE = LS-DRAW + LS-A
             END-IF
         WHEN "binomial"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-N LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-P LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-F
             PERFORM LS-A TIMES
                 CALL "LOOT-RNG-FLOAT" USING LS-G
                 IF LS-G < LS-F
                     ADD 1 TO L-VALUE
                 END-IF
             END-PERFORM
         WHEN "add"
         WHEN "mul"
         WHEN "min"
         WHEN "max"
         WHEN "avg"
             EVALUATE LS-KIND
                 WHEN "mul"
                     MOVE 1 TO LS-ACC
                 WHEN "min"
                     MOVE 2147483647 TO LS-ACC
                 WHEN "max"
                     MOVE -2147483648 TO LS-ACC
                 WHEN OTHER
                     MOVE 0 TO LS-ACC
             END-EVALUATE
             MOVE 0 TO LS-COUNT
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUTS LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-INT-EVAL" USING LS-SLOT LS-CHILD LS-TERM
                 ADD 1 TO LS-COUNT
                 EVALUATE LS-KIND
                     WHEN "mul"
                         COMPUTE LS-ACC = LS-ACC * LS-TERM ON SIZE ERROR MOVE 1 TO LW-ERR
                     WHEN "min"
                         IF LS-TERM < LS-ACC
                             MOVE LS-TERM TO LS-ACC
                         END-IF
                     WHEN "max"
                         IF LS-TERM > LS-ACC
                             MOVE LS-TERM TO LS-ACC
                         END-IF
                     WHEN OTHER
                         ADD LS-TERM TO LS-ACC
                 END-EVALUATE
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             IF LS-KIND = "avg"
                 IF LS-COUNT = 0
                     MOVE 1 TO LW-ERR
                 ELSE
                     COMPUTE LS-ACC = LS-ACC / LS-COUNT
                 END-IF
             END-IF
             CALL "LOOT-INT-FIT" USING LS-ACC L-VALUE
         WHEN "negate"
         WHEN "abs"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUT LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             IF LS-KIND = "negate"
                 COMPUTE LS-ACC = 0 - LS-A
             ELSE
                 COMPUTE LS-ACC = FUNCTION ABS(LS-A)
             END-IF
             CALL "LOOT-INT-FIT" USING LS-ACC L-VALUE
         WHEN "sub"
         WHEN "div"
         WHEN "floor_div"
         WHEN "mod"
         WHEN "floor_mod"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-LEFT LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RIGHT LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             IF LS-KIND NOT = "sub" AND LS-B = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 EVALUATE LS-KIND
                     WHEN "sub"
                         COMPUTE LS-ACC = LS-A - LS-B
                     WHEN "div"
                         COMPUTE LS-ACC = LS-A / LS-B
                     WHEN "floor_div"
                         COMPUTE LS-ACC = FUNCTION INTEGER(LS-A / LS-B)
                     WHEN "mod"
                         COMPUTE LS-ACC = FUNCTION REM(LS-A, LS-B)
                     WHEN OTHER
                         COMPUTE LS-ACC = FUNCTION MOD(LS-A, LS-B)
                 END-EVALUATE
                 CALL "LOOT-INT-FIT" USING LS-ACC L-VALUE
             END-IF
         WHEN "pow"
*>           powExact: 0^0 is an error; a negative exponent only for the bases 1 and -1 (else an error); an overflow is an error.
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-BASE LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-EXPONENT LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             EVALUATE TRUE
                 WHEN LS-A = 0 AND LS-B = 0
                     MOVE 1 TO LW-ERR
                 WHEN LS-A = 1 OR LS-B = 0
                     MOVE 1 TO L-VALUE
                 WHEN LS-A = -1
                     IF FUNCTION MOD(LS-B, 2) = 0
                         MOVE 1 TO L-VALUE
                     ELSE
                         MOVE -1 TO L-VALUE
                     END-IF
                 WHEN LS-B < 0
                     MOVE 1 TO LW-ERR
                 WHEN LS-A = 0
                     MOVE 0 TO L-VALUE
                 WHEN OTHER
                     MOVE 1 TO LS-ACC
                     PERFORM LS-B TIMES
                         COMPUTE LS-ACC = LS-ACC * LS-A
                         IF LS-ACC > 2147483647 OR LS-ACC < -2147483648
                             MOVE 1 TO LW-ERR
                             EXIT PERFORM
                         END-IF
                     END-PERFORM
                     IF LW-ERR = 0
                         MOVE LS-ACC TO L-VALUE
                     END-IF
             END-EVALUATE
         WHEN "from_float"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-F
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE LS-F BY REFERENCE L-VALUE
         WHEN "weighted_list"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-DIST LS-MEMBER
             MOVE 0 TO LS-TOTAL
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-WEIGHT LS-OTHER
                 CALL "LOOT-J-NUMBER" USING LS-SLOT LS-OTHER LS-WEIGHT LS-OK
                 COMPUTE LS-TOTAL = LS-TOTAL + LS-WEIGHT
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             IF LS-TOTAL = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL "LOOT-RNG-INT" USING LS-TOTAL LS-DRAW
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-WEIGHT LS-OTHER
                     CALL "LOOT-J-NUMBER" USING LS-SLOT LS-OTHER LS-WEIGHT LS-OK
                     COMPUTE LS-DRAW = LS-DRAW - LS-WEIGHT
                     IF LS-DRAW < 0
                         CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-DATA LS-OTHER
                         CALL "LOOT-INT-EVAL" USING LS-SLOT LS-OTHER L-VALUE
                         MOVE 0 TO LS-CHILD
                     ELSE
                         MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
                     END-IF
                 END-PERFORM
             END-IF
         WHEN "conditional"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CONDITION LS-MEMBER
             CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
             IF LS-OK = 1
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-TRUE LS-MEMBER
             ELSE
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-FALSE LS-MEMBER
             END-IF
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER L-VALUE
         WHEN "number_dispatcher"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CASES LS-MEMBER
             MOVE 0 TO LS-CHILD LS-OTHER
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-CONDITION LS-MEMBER
                 CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
                 IF LS-OK = 1
                     CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-VALUE LS-OTHER
                     MOVE 0 TO LS-CHILD
                 ELSE
                     MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
                 END-IF
             END-PERFORM
             IF LS-OTHER = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-DEFAULT LS-OTHER
             END-IF
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-OTHER L-VALUE
         WHEN OTHER
             MOVE 1 TO LW-ERR
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-INT-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-INT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-SAVED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE.
     MOVE LW-ERR TO WS-SAVED
     MOVE 0 TO LW-ERR
     CALL "LOOT-INT-EVAL" USING L-SLOT L-NODE L-VALUE
     IF LW-ERR NOT = 0
         MOVE 0 TO L-VALUE
     END-IF
     MOVE WS-SAVED TO LW-ERR
     GOBACK.
 END PROGRAM LOOT-INT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-FLOAT-EVAL IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(48) VALUE "context_float_provider".
 01 WS-N-INPUTS            PIC X(32) VALUE "inputs".
 01 WS-N-INPUT             PIC X(32) VALUE "input".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-N-LEFT              PIC X(32) VALUE "left".
 01 WS-N-RIGHT             PIC X(32) VALUE "right".
 01 WS-N-AMOUNT            PIC X(32) VALUE "amount".
 01 WS-N-BASE              PIC X(32) VALUE "base".
 01 WS-N-EXPONENT          PIC X(32) VALUE "exponent".
 01 WS-N-DIST              PIC X(32) VALUE "distribution".
 01 WS-N-DATA              PIC X(32) VALUE "data".
 01 WS-N-WEIGHT            PIC X(32) VALUE "weight".
 01 WS-N-CONDITION         PIC X(32) VALUE "condition".
 01 WS-N-TRUE              PIC X(32) VALUE "on_true".
 01 WS-N-FALSE             PIC X(32) VALUE "on_false".
 01 WS-N-CASES             PIC X(32) VALUE "cases".
 01 WS-N-DEFAULT           PIC X(32) VALUE "default".
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OTHER               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-ACC                 FLOAT-LONG.
 01 LS-TERM                FLOAT-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-INT                 BINARY-LONG.
 01 LS-TOTAL               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-WEIGHT              FLOAT-LONG.
 01 LS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE.
     MOVE 0 TO L-VALUE
     MOVE L-SLOT TO LS-SLOT
     MOVE L-NODE TO LS-NODE
     IF LS-NODE = 0
         GOBACK
     END-IF
     EVALUATE LDS-JN-TYPE(LS-SLOT, LS-NODE)
         WHEN JT-NUMBER
             MOVE LDS-JN-NUM(LS-SLOT, LS-NODE) TO L-VALUE
             CALL "LOOT-F32" USING L-VALUE
             GOBACK
         WHEN JT-STRING
             CALL "LOOT-HOLDER" USING WS-REGISTRY LS-SLOT LS-NODE
             IF LS-NODE = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-NODE L-VALUE
             END-IF
             GOBACK
         WHEN JT-OBJECT
             CONTINUE
         WHEN OTHER
             MOVE 1 TO LW-ERR
             GOBACK
     END-EVALUATE
     CALL "LOOT-J-KIND" USING LS-SLOT LS-NODE LS-KIND
     EVALUATE LS-KIND
         WHEN "constant"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER L-VALUE
         WHEN "uniform"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-MIN LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-MAX LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             MOVE LS-A TO L-VALUE
             IF LS-A < LS-B
                 CALL "LOOT-RNG-FLOAT" USING LS-TERM
                 CALL STATIC "cc_f64_sub" USING BY REFERENCE LS-B BY REFERENCE LS-A BY REFERENCE LS-ACC
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-TERM BY REFERENCE LS-ACC BY REFERENCE LS-B
                 CALL "LOOT-F32" USING LS-B
                 CALL STATIC "cc_f64_add" USING BY REFERENCE LS-B BY REFERENCE LS-A BY REFERENCE L-VALUE
                 CALL "LOOT-F32" USING L-VALUE
             END-IF
         WHEN "add"
         WHEN "mul"
         WHEN "min"
         WHEN "max"
             EVALUATE LS-KIND
                 WHEN "mul"
                     MOVE 1 TO LS-ACC
                 WHEN "min"
                     MOVE 3.4028234663852886E38 TO LS-ACC
                 WHEN "max"
                     MOVE -3.4028234663852886E38 TO LS-ACC
                 WHEN OTHER
                     MOVE 0 TO LS-ACC
             END-EVALUATE
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUTS LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-CHILD LS-TERM
                 EVALUATE LS-KIND
                     WHEN "mul"
                         CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-ACC BY REFERENCE LS-TERM BY REFERENCE LS-A
                         CALL "LOOT-F32" USING LS-A
                         MOVE LS-A TO LS-ACC
                     WHEN "min"
                         IF LS-TERM < LS-ACC
                             MOVE LS-TERM TO LS-ACC
                         END-IF
                     WHEN "max"
                         IF LS-TERM > LS-ACC
                             MOVE LS-TERM TO LS-ACC
                         END-IF
                     WHEN OTHER
                         CALL STATIC "cc_f64_add" USING BY REFERENCE LS-ACC BY REFERENCE LS-TERM BY REFERENCE LS-A
                         CALL "LOOT-F32" USING LS-A
                         MOVE LS-A TO LS-ACC
                 END-EVALUATE
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             MOVE LS-ACC TO L-VALUE
         WHEN "negate"
         WHEN "abs"
         WHEN "ceil"
         WHEN "floor"
         WHEN "round"
         WHEN "truncate"
         WHEN "sqrt"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             EVALUATE LS-KIND
                 WHEN "negate"
                     COMPUTE L-VALUE = 0 - LS-A
                 WHEN "abs"
                     CALL STATIC "cc_f64_abs_f32" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
                 WHEN "ceil"
                     CALL STATIC "cc_f64_ceil" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
                 WHEN "floor"
                     CALL STATIC "cc_f64_floor" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
                 WHEN "round"
                     CALL STATIC "cc_f64_round_f32" USING BY REFERENCE LS-A BY REFERENCE LS-INT
                     MOVE LS-INT TO L-VALUE
                 WHEN "truncate"
                     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE LS-A BY REFERENCE LS-INT
                     MOVE LS-INT TO L-VALUE
                 WHEN OTHER
                     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
                     CALL "LOOT-F32" USING L-VALUE
             END-EVALUATE
         WHEN "avg"
         WHEN "length"
*>           avg: the float sum over (float) count; length: sqrt of the sum of squares (every step rounded to binary32).
             MOVE 0 TO LS-ACC LS-COUNT
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUTS LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-CHILD LS-TERM
                 ADD 1 TO LS-COUNT
                 IF LS-KIND = "length"
                     MOVE LS-TERM TO LS-A
                     CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-TERM BY REFERENCE LS-A BY REFERENCE LS-B
                     CALL "LOOT-F32" USING LS-B
                     MOVE LS-B TO LS-TERM
                 END-IF
                 CALL STATIC "cc_f64_add" USING BY REFERENCE LS-ACC BY REFERENCE LS-TERM BY REFERENCE LS-A
                 CALL "LOOT-F32" USING LS-A
                 MOVE LS-A TO LS-ACC
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             IF LS-KIND = "length"
                 CALL STATIC "cc_f64_sqrt" USING BY REFERENCE LS-ACC BY REFERENCE L-VALUE
                 CALL "LOOT-F32" USING L-VALUE
             ELSE
                 IF LS-COUNT = 0
                     MOVE 1 TO LW-ERR
                 ELSE
                     MOVE LS-COUNT TO LS-B
                     CALL STATIC "cc_f64_div" USING BY REFERENCE LS-ACC BY REFERENCE LS-B BY REFERENCE L-VALUE
                     CALL "LOOT-F32" USING L-VALUE
                 END-IF
             END-IF
         WHEN "sin"
         WHEN "cos"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             IF LS-KIND = "sin"
                 CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
             ELSE
                 CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE LS-A BY REFERENCE L-VALUE
             END-IF
         WHEN "mod"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-LEFT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RIGHT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             IF LS-B = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL STATIC "cc_f64_fmod" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
                 CALL "LOOT-F32" USING L-VALUE
             END-IF
         WHEN "pow"
*>           0^0 and a negative base with a fractional exponent are NaN, a result beyond the float range is infinite: errors (getFloat 0).
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-BASE LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-EXPONENT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             CALL STATIC "cc_f64_floor" USING BY REFERENCE LS-B BY REFERENCE LS-ACC
             IF (LS-A = 0 AND LS-B = 0) OR (LS-A < 0 AND LS-ACC NOT = LS-B)
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL STATIC "cc_f64_pow" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
                 IF L-VALUE > 3.4028234663852886E38 OR L-VALUE < -3.4028234663852886E38
                     MOVE 1 TO LW-ERR
                 ELSE
                     CALL "LOOT-F32" USING L-VALUE
                 END-IF
             END-IF
         WHEN "sub"
         WHEN "div"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-LEFT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-A
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-RIGHT LS-MEMBER
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER LS-B
             IF LS-KIND = "sub"
                 CALL STATIC "cc_f64_sub" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
             ELSE
                 IF LS-B = 0
                     MOVE 1 TO LW-ERR
                 ELSE
                     CALL STATIC "cc_f64_div" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
                 END-IF
             END-IF
             CALL "LOOT-F32" USING L-VALUE
         WHEN "from_int"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-INPUT LS-MEMBER
             CALL "LOOT-INT-EVAL" USING LS-SLOT LS-MEMBER LS-INT
             CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE LS-INT BY REFERENCE L-VALUE
         WHEN "enchantment_level"
             MOVE 0 TO LS-LEVEL
             IF LW-C-ENCH-SET = 1
                 MOVE LW-C-ENCH-LEVEL TO LS-LEVEL
             END-IF
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-AMOUNT LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING LS-SLOT LS-MEMBER LS-LEVEL L-VALUE
         WHEN "weighted_list"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-DIST LS-MEMBER
             MOVE 0 TO LS-TOTAL
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-WEIGHT LS-OTHER
                 CALL "LOOT-J-NUMBER" USING LS-SLOT LS-OTHER LS-WEIGHT LS-OK
                 COMPUTE LS-TOTAL = LS-TOTAL + LS-WEIGHT
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             IF LS-TOTAL = 0
                 MOVE 1 TO LW-ERR
             ELSE
                 CALL "LOOT-RNG-INT" USING LS-TOTAL LS-DRAW
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-WEIGHT LS-OTHER
                     CALL "LOOT-J-NUMBER" USING LS-SLOT LS-OTHER LS-WEIGHT LS-OK
                     COMPUTE LS-DRAW = LS-DRAW - LS-WEIGHT
                     IF LS-DRAW < 0
                         CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-DATA LS-OTHER
                         CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-OTHER L-VALUE
                         MOVE 0 TO LS-CHILD
                     ELSE
                         MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
                     END-IF
                 END-PERFORM
             END-IF
         WHEN "conditional"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CONDITION LS-MEMBER
             CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
             IF LS-OK = 1
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-TRUE LS-MEMBER
             ELSE
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-FALSE LS-MEMBER
             END-IF
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-MEMBER L-VALUE
         WHEN "number_dispatcher"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CASES LS-MEMBER
             MOVE 0 TO LS-CHILD LS-OTHER
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(LS-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-CONDITION LS-MEMBER
                 CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
                 IF LS-OK = 1
                     CALL "LOOT-J-MEMBER" USING LS-SLOT LS-CHILD WS-N-VALUE LS-OTHER
                     MOVE 0 TO LS-CHILD
                 ELSE
                     MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
                 END-IF
             END-PERFORM
             IF LS-OTHER = 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-DEFAULT LS-OTHER
             END-IF
             CALL "LOOT-FLOAT-EVAL" USING LS-SLOT LS-OTHER L-VALUE
         WHEN OTHER
             MOVE 1 TO LW-ERR
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-FLOAT-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-FLOAT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-SAVED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE.
     MOVE LW-ERR TO WS-SAVED
     MOVE 0 TO LW-ERR
     CALL "LOOT-FLOAT-EVAL" USING L-SLOT L-NODE L-VALUE
     IF LW-ERR NOT = 0
         MOVE 0 TO L-VALUE
     END-IF
     MOVE WS-SAVED TO LW-ERR
     GOBACK.
 END PROGRAM LOOT-FLOAT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-LEVEL-EVAL IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-N-BASE              PIC X(32) VALUE "base".
 01 WS-N-PER               PIC X(32) VALUE "per_level_above_first".
 01 WS-N-VALUES            PIC X(32) VALUE "values".
 01 WS-N-FALLBACK          PIC X(32) VALUE "fallback".
 01 WS-N-POWER             PIC X(32) VALUE "power".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-N-NUMERATOR         PIC X(32) VALUE "numerator".
 01 WS-N-DENOMINATOR       PIC X(32) VALUE "denominator".
 01 WS-N-ADDED             PIC X(32) VALUE "added".
 LOCAL-STORAGE SECTION.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-C                   FLOAT-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-LEVEL-F             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-LEVEL L-VALUE.
     MOVE 0 TO L-VALUE
     IF L-NODE = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-NUMBER
         MOVE LDS-JN-NUM(L-SLOT, L-NODE) TO L-VALUE
         CALL "LOOT-F32" USING L-VALUE
         GOBACK
     END-IF
     CALL "LOOT-J-KIND" USING L-SLOT L-NODE LS-KIND
     MOVE L-LEVEL TO LS-LEVEL-F
     EVALUATE LS-KIND
         WHEN "linear"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-BASE LS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT LS-MEMBER LS-A LS-OK
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-PER LS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT LS-MEMBER LS-B LS-OK
             CALL "LOOT-F32" USING LS-A
             CALL "LOOT-F32" USING LS-B
             COMPUTE LS-C = L-LEVEL - 1
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-B BY REFERENCE LS-C BY REFERENCE LS-LEVEL-F
             CALL "LOOT-F32" USING LS-LEVEL-F
             CALL STATIC "cc_f64_add" USING BY REFERENCE LS-A BY REFERENCE LS-LEVEL-F BY REFERENCE L-VALUE
             CALL "LOOT-F32" USING L-VALUE
         WHEN "lookup"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-VALUES LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0 AND L-LEVEL >= 1 AND L-LEVEL <= LDS-JN-COUNT(L-SLOT, LS-MEMBER)
                 MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
                 PERFORM VARYING LS-I FROM 2 BY 1 UNTIL LS-I > L-LEVEL
                     MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
                 END-PERFORM
                 CALL "LOOT-J-NUMBER" USING L-SLOT LS-CHILD L-VALUE LS-OK
                 CALL "LOOT-F32" USING L-VALUE
             ELSE
                 CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-FALLBACK LS-MEMBER
                 CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL L-VALUE
             END-IF
         WHEN "exponent"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-BASE LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL LS-A
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-POWER LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL LS-B
             CALL STATIC "cc_f64_pow" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
             CALL "LOOT-F32" USING L-VALUE
         WHEN "clamped"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-VALUE LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL LS-A
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MIN LS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT LS-MEMBER LS-B LS-OK
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MAX LS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT LS-MEMBER LS-C LS-OK
             CALL "LOOT-F32" USING LS-B
             CALL "LOOT-F32" USING LS-C
             CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE LS-C
                 BY REFERENCE L-VALUE
         WHEN "fraction"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-NUMERATOR LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL LS-A
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-DENOMINATOR LS-MEMBER
             CALL "LOOT-LEVEL-EVAL" USING L-SLOT LS-MEMBER L-LEVEL LS-B
             IF LS-B NOT = 0
                 CALL STATIC "cc_f64_div" USING BY REFERENCE LS-A BY REFERENCE LS-B BY REFERENCE L-VALUE
                 CALL "LOOT-F32" USING L-VALUE
             END-IF
         WHEN "levels_squared"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ADDED LS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT LS-MEMBER LS-A LS-OK
             COMPUTE LS-B = L-LEVEL * L-LEVEL
             CALL STATIC "cc_f64_add" USING BY REFERENCE LS-B BY REFERENCE LS-A BY REFERENCE L-VALUE
             CALL "LOOT-F32" USING L-VALUE
         WHEN OTHER
             MOVE 1 TO LW-ERR
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-LEVEL-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-INT-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "context_int_provider".
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SEQUENCE            PIC X(112) VALUE SPACES.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(112).
 COPY LOOTCTX.
 01 L-VALUE                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME LOOT-CONTEXT L-VALUE L-FOUND.
     MOVE 0 TO L-VALUE L-FOUND
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-NAME WS-SLOT
     IF WS-SLOT > 0
         MOVE 1 TO WS-NODE
         MOVE 1 TO L-FOUND
         CALL "LOOT-INT-GET" USING WS-SLOT WS-NODE L-VALUE
     END-IF
     GOBACK.
 END PROGRAM LOOT-INT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-FLOAT-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "context_float_provider".
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SEQUENCE            PIC X(112) VALUE SPACES.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(112).
 COPY LOOTCTX.
 01 L-VALUE                FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME LOOT-CONTEXT L-VALUE L-FOUND.
     MOVE 0 TO L-VALUE L-FOUND
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-NAME WS-SLOT
     IF WS-SLOT > 0
         MOVE 1 TO WS-NODE
         MOVE 1 TO L-FOUND
         CALL "LOOT-FLOAT-GET" USING WS-SLOT WS-NODE L-VALUE
     END-IF
     GOBACK.
 END PROGRAM LOOT-FLOAT-OF.
