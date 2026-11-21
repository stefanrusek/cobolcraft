*> Entity models part 9, section 9 dropped items, item clusters and the ominous item spawner (docs/protocol/34-entity-models-9-non-living-entities.md):
*>   EF9-ITEM-COPIES IN(1 stack count) OUT(1 renderedAmount: 1, 2, 3, 4, 5);
*>   EF9-ITEM-SEED IN(1 item registry id, 2 damage value, 3 the stack is empty) OUT(1 seedFor: 187 for an empty stack, else id + damage);
*>   EF9-ITEM-POSE IN(1 ageInTicks, 2 bobOffs, 3 the model's minimum y) OUT(1 the translation y = bob + base, 2 the spin in radians): 9.2 steps 1 and 2;
*>   EF9-CLUSTER IN(1 copies, 2 seed, 3 the model's z size) OUT(1 copies, then x, y, z of each copy relative to the item's origin): submitMultipleFromCount, thick models
*>     (zs > 0.0625) once unshifted and the others moved by three draws, flat models stacked along z from -(step (n - 1)) / 2 by step = zs x 1.5, the others scattered by two
*>     draws x 0.15 x 0.5; the draws are nextFloat() of the Java LCG (JRAND, core/src/rng-java.cob) seeded with the seed;
*>   EF9-SPAWNER-OPS IN(1 ageInTicks) OUT(ops: count, then code and three values per op; 2 scale, 3 rotate Y degrees): 9.3 (scale age / 50 while age <= 50, rotate Y by wrapDegrees(age x 40));
*>   EF9-SPAWNER-LIGHT OUT(1 the fixed light coordinates 15728880).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ITEM-COPIES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE TRUE
         WHEN L-I(1) <= 1
             MOVE 1 TO L-O(1)
         WHEN L-I(1) <= 16
             MOVE 2 TO L-O(1)
         WHEN L-I(1) <= 32
             MOVE 3 TO L-O(1)
         WHEN L-I(1) <= 48
             MOVE 4 TO L-O(1)
         WHEN OTHER
             MOVE 5 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-ITEM-COPIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ITEM-SEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 187 TO L-O(1)
     IF L-I(3) = 0
         COMPUTE L-O(1) = L-I(1) + L-I(2)
     END-IF
     GOBACK.
 END PROGRAM EF9-ITEM-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ITEM-POSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION SIN(L-I(1) / 10 + L-I(2)) * 0.1 + 0.1 - L-I(3) + 0.0625
     COMPUTE L-O(2) = L-I(1) / 20 + L-I(2)
     GOBACK.
 END PROGRAM EF9-ITEM-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-CLUSTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-N
     MOVE WS-N TO L-O(1)
     IF WS-N < 1
         MOVE 0 TO L-O(1)
         GOBACK
     END-IF
     MOVE L-I(2) TO WS-SEED
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     IF L-I(3) > 0.0625
         MOVE 0 TO L-O(2) L-O(3) L-O(4)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K >= WS-N
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R3
             COMPUTE WS-B = WS-K * 3 + 2
             COMPUTE L-O(WS-B) = (WS-R1 * 2 - 1) * 0.15
             COMPUTE L-O(WS-B + 1) = (WS-R2 * 2 - 1) * 0.15
             COMPUTE L-O(WS-B + 2) = (WS-R3 * 2 - 1) * 0.15
         END-PERFORM
     ELSE
         COMPUTE WS-STEP = L-I(3) * 1.5
         COMPUTE WS-Z = 0 - (WS-STEP * (WS-N - 1)) / 2
         MOVE 0 TO L-O(2) L-O(3)
         MOVE WS-Z TO L-O(4)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K >= WS-N
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
             COMPUTE WS-B = WS-K * 3 + 2
             COMPUTE L-O(WS-B) = (WS-R1 * 2 - 1) * 0.15 * 0.5
             COMPUTE L-O(WS-B + 1) = (WS-R2 * 2 - 1) * 0.15 * 0.5
             COMPUTE L-O(WS-B + 2) = WS-Z + WS-STEP * WS-K
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EF9-CLUSTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-SPAWNER-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO WS-N
     IF L-I(1) <= 50
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = L-I(1) / 50
         MOVE L-O(WS-K + 1) TO L-O(WS-K + 2) L-O(WS-K + 3)
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 3 TO L-O(WS-K)
     COMPUTE WS-A = L-I(1) * 40
     COMPUTE L-O(WS-K + 1) = WS-A - 360 * FUNCTION INTEGER((WS-A + 180) / 360)
     MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF9-SPAWNER-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-SPAWNER-LIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 15728880 TO L-O(1)
     GOBACK.
 END PROGRAM EF9-SPAWNER-LIGHT.
