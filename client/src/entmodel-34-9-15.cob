*> Entity models part 9, section 15 lightning bolt (docs/protocol/34-entity-models-9-non-living-entities.md): the geometry. The renderer's pipeline (colour factors source alpha and one, depth tested, never
*> culled) is not in the entity pass (the shim has no additive pipeline: tasks T28900 for the dragon's rays), so the bolt is not drawn yet; these programs give its vertices.
*>   (A seed is a Java long: only its low 48 bits matter to the generator, so a negative seed is taken modulo 2 ** 48; seeds are exact below 2 ** 53 in the FLOAT-LONG input.)
*>   EF9-LIGHTNING-PATH IN(1 the entity's seed) OUT(1 to 8 xs[0..7], 9 to 16 zs[0..7], 17 endX, 18 endZ): the path table (i = 7 down to 0: xs[i], zs[i] then x += nextInt(11) - 5, z += nextInt(11) - 5);
*>   EF9-LIGHTNING-STEP IN(1 seed, 2 pass j 0 to 3, 3 step n 0 to 13) OUT(1 branch k, 2 layer, 3 prevX, 4 prevZ, 5 px, 6 pz, 7 wTop, 8 wBot): the n-th layer step of a pass (a fresh generator of the
*>     seed at its start; branch 0 runs layers 7 down to 0 with draws nextInt(11) - 5, branch 1 layers 6 to 4 and branch 2 layers 5 to 3 with nextInt(31) - 15, x before z);
*>   EF9-LIGHTNING-QUAD IN(1 x_new, 2 z_new, 3 x_prev, 4 z_prev, 5 layer, 6 wTop, 7 wBot, 8 to 11 f1 to f4) OUT(1 to 12 the four vertices: sgn(f, w) = +w when f else -w, w7 = wTop for the previous
*>     (upper) point and w8 = wBot for the new one);
*>   EF9-LIGHTNING-COLOR OUT(1 to 4 r, g, b, a = 0.45, 0.45, 0.5, 0.3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHTNING-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 11.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-SEED = FUNCTION MOD(L-I(1), 281474976710656)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     MOVE 0 TO WS-X WS-Z
     PERFORM VARYING WS-I FROM 7 BY -1 UNTIL WS-I < 0
         MOVE WS-X TO L-O(WS-I + 1)
         MOVE WS-Z TO L-O(WS-I + 9)
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-D
         COMPUTE WS-X = WS-X + WS-D - 5
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-D
         COMPUTE WS-Z = WS-Z + WS-D - 5
     END-PERFORM
     MOVE WS-X TO L-O(17)
     MOVE WS-Z TO L-O(18)
     GOBACK.
 END PROGRAM EF9-LIGHTNING-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHTNING-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P.
    05 WS-PV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-B11                 BINARY-LONG VALUE 11.
 01 WS-B31                 BINARY-LONG VALUE 31.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PRX                 BINARY-LONG.
 01 WS-PRZ                 BINARY-LONG.
 01 WS-ENDX                BINARY-LONG.
 01 WS-ENDZ                BINARY-LONG.
 01 WS-WT                  FLOAT-LONG.
 01 WS-WB                  FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     CALL "EF9-LIGHTNING-PATH" USING L-IN WS-P
     MOVE WS-PV(17) TO WS-ENDX
     MOVE WS-PV(18) TO WS-ENDZ
     COMPUTE WS-SEED = FUNCTION MOD(L-I(1), 281474976710656)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     MOVE 0 TO WS-N WS-DONE
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2 OR WS-DONE = 1
         COMPUTE WS-START = 7 - WS-K
         IF WS-K = 0
             MOVE 0 TO WS-END
         ELSE
             COMPUTE WS-END = WS-START - 3 + 1
         END-IF
         COMPUTE WS-PX = WS-PV(WS-START + 1) - WS-ENDX
         COMPUTE WS-PZ = WS-PV(WS-START + 9) - WS-ENDZ
         PERFORM VARYING WS-LAYER FROM WS-START BY -1 UNTIL WS-LAYER < WS-END OR WS-DONE = 1
             MOVE WS-PX TO WS-PRX
             MOVE WS-PZ TO WS-PRZ
             IF WS-K = 0
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B11 WS-D
                 COMPUTE WS-PX = WS-PX + WS-D - 5
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B11 WS-D
                 COMPUTE WS-PZ = WS-PZ + WS-D - 5
             ELSE
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B31 WS-D
                 COMPUTE WS-PX = WS-PX + WS-D - 15
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B31 WS-D
                 COMPUTE WS-PZ = WS-PZ + WS-D - 15
             END-IF
             COMPUTE WS-WT = 0.1 + L-I(2) * 0.2
             MOVE WS-WT TO WS-WB
             IF WS-K = 0
                 COMPUTE WS-WT = WS-WT * (WS-LAYER * 0.1 + 1)
                 COMPUTE WS-WB = WS-WB * ((WS-LAYER - 1) * 0.1 + 1)
             END-IF
             IF WS-N = L-I(3)
                 MOVE WS-K TO L-O(1)
                 MOVE WS-LAYER TO L-O(2)
                 MOVE WS-PRX TO L-O(3)
                 MOVE WS-PRZ TO L-O(4)
                 MOVE WS-PX TO L-O(5)
                 MOVE WS-PZ TO L-O(6)
                 MOVE WS-WT TO L-O(7)
                 MOVE WS-WB TO L-O(8)
                 MOVE 1 TO WS-DONE
             END-IF
             ADD 1 TO WS-N
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-LIGHTNING-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHTNING-QUAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 4
         COMPUTE WS-B = WS-V * 3 - 2
*>       vertices 1 and 4 use the new point and wBot with (f1, f2) and (f3, f4); 2 and 3 the previous point and wTop with (f1, f2) and (f3, f4)
         IF WS-V = 1 OR WS-V = 2
             MOVE L-I(8) TO WS-F1
             MOVE L-I(9) TO WS-F2
         ELSE
             MOVE L-I(10) TO WS-F1
             MOVE L-I(11) TO WS-F2
         END-IF
         IF WS-V = 1 OR WS-V = 4
             MOVE L-I(7) TO WS-W
             COMPUTE L-O(WS-B + 1) = L-I(5) * 16
         ELSE
             MOVE L-I(6) TO WS-W
             COMPUTE L-O(WS-B + 1) = (L-I(5) + 1) * 16
         END-IF
         MOVE WS-W TO WS-S1
         IF WS-F1 = 0
             COMPUTE WS-S1 = 0 - WS-W
         END-IF
         MOVE WS-W TO WS-S2
         IF WS-F2 = 0
             COMPUTE WS-S2 = 0 - WS-W
         END-IF
         IF WS-V = 1 OR WS-V = 4
             COMPUTE L-O(WS-B) = L-I(1) + WS-S1
             COMPUTE L-O(WS-B + 2) = L-I(2) + WS-S2
         ELSE
             COMPUTE L-O(WS-B) = L-I(3) + WS-S1
             COMPUTE L-O(WS-B + 2) = L-I(4) + WS-S2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-LIGHTNING-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-LIGHTNING-COLOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.45 TO L-O(1) L-O(2)
     MOVE 0.5 TO L-O(3)
     MOVE 0.3 TO L-O(4)
     GOBACK.
 END PROGRAM EF9-LIGHTNING-COLOR.
