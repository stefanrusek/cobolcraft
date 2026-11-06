*> The deterministic pseudo-random source: the integer hash H of standin-content §1.4.1, used by
*> the mob rules (§12.3 wander decisions, §12.4 spawning) and the weather (§14.3). The same inputs
*> always give the same result, so two implementations given the same state agree.
*>
*>   mix(v), 0 <= v < 2^32: v <- v x 2654435761 mod 2^32; swap the 16-bit halves;
*>                          v <- v x 2246822519 mod 2^32; swap the 16-bit halves.
*>   H(v1, ..., vn): h <- 2166136261; for each vi, h <- mix((h + (vi mod 2^32)) mod 2^32).
*> "mod" is the non-negative remainder (-1 mod 2^32 = 4294967295). The products reach 2^64, beyond a
*> signed 64-bit field: the arithmetic runs in COMPUTE's intermediate precision, with the
*> multipliers in VALUE clauses (literal arithmetic folds to 64 bits).
*>
*> Entry points:
*>   RNG-MIX USING v, result (BINARY-DOUBLE, 0 <= v < 2^32)
*>   RNG-HASH USING count (BINARY-LONG, 1 to 16), values (table of 16 BINARY-DOUBLE, the first
*>     count used), result (BINARY-DOUBLE, 0 <= result < 2^32)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RNG-MIX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M1                  BINARY-DOUBLE UNSIGNED VALUE 2654435761.
 01 WS-M2                  BINARY-DOUBLE UNSIGNED VALUE 2246822519.
 01 WS-MOD                 BINARY-DOUBLE UNSIGNED VALUE 4294967296.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-V                    BINARY-DOUBLE.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-V L-RESULT.
     COMPUTE WS-V = FUNCTION MOD(L-V * WS-M1, WS-MOD)
     COMPUTE WS-V = WS-V / 65536 + FUNCTION MOD(WS-V, 65536) * 65536
     COMPUTE WS-V = FUNCTION MOD(WS-V * WS-M2, WS-MOD)
     COMPUTE L-RESULT = WS-V / 65536 + FUNCTION MOD(WS-V, 65536) * 65536
     GOBACK.
 END PROGRAM RNG-MIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RNG-HASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MOD                 BINARY-DOUBLE UNSIGNED VALUE 4294967296.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-VALUES.
    05 L-VALUE             BINARY-DOUBLE OCCURS 16 TIMES.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-COUNT L-VALUES L-RESULT.
     MOVE 2166136261 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-V = FUNCTION MOD(WS-H + FUNCTION MOD(L-VALUE(WS-I), WS-MOD), WS-MOD)
         CALL "RNG-MIX" USING WS-V WS-H
     END-PERFORM
     MOVE WS-H TO L-RESULT
     GOBACK.
 END PROGRAM RNG-HASH.
