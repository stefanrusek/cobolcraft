*> Aquifers (docs/protocol/10 section 9). First slice: the global fluid picker only (9.1: lava below y -54, water below the sea
*> level 63, else air), which is what computeSubstance returns for every position above skipSamplingAboveY and what an
*> aquifer of a single status gives.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUIFER-SUBSTANCE.
*> USING x, y, z (BINARY-LONG), density (FLOAT-LONG, 0 or less: the caller has handled the solid case), kind out (BINARY-LONG: 1 air,
*> 2 water, 3 lava).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-D L-KIND.
     EVALUATE TRUE
         WHEN L-Y < -54
             MOVE 3 TO L-KIND
         WHEN L-Y < 63
             MOVE 2 TO L-KIND
         WHEN OTHER
             MOVE 1 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM AQUIFER-SUBSTANCE.
