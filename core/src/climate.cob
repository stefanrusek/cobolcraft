*> Climate sampling and the multi-noise biome source (docs/protocol/10 sections 6.1 and 7.1 to 7.3; CLIMATE.cpy).
*> The six router functions (temperature, vegetation = humidity, continents, erosion, depth, ridges = weirdness)
*> are density functions of the content's data, evaluated by density.cob at the block position of the quart cell,
*> and quantised; the biome of a target is the parameter point of the smallest fitness.
*>
*> Entry points:
*>   CLIMATE-F32-QUANTIZE USING v (FLOAT-LONG, narrowed to float32 first), result out (BINARY-DOUBLE)
*>   CLIMATE-SAMPLE USING qx, qy, qz (BINARY-LONG quart cell), target out (6 BINARY-DOUBLE: T, H, C, E, D, W)
*>   CLIMATE-POINTS-RESET                      empties the point table
*>   CLIMATE-POINT-ADD USING biome (PIC X(40)), minimums (6 BINARY-DOUBLE), maximums (6), offset (BINARY-DOUBLE)
*>   CLIMATE-POINTS-LOAD USING preset (BINARY-LONG, 1 the Nether preset of the content library), count out
*>   CLIMATE-FIND USING target (6 BINARY-DOUBLE), index out (1-based, 0 for an empty table), biome out (PIC X(40)),
*>     fitness out (BINARY-DOUBLE): 7.3, the first point of the smallest fitness
*>   CLIMATE-BIOME-AT USING qx, qy, qz, index out, biome out: the two above in one

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-F32-QUANTIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 10000.
 01 WS-V                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-V L-RESULT.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-V WS-V
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V WS-SCALE WS-P
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-R
     CALL STATIC "cc_f64_to_i64" USING BY REFERENCE WS-R L-RESULT
     GOBACK.
 END PROGRAM CLIMATE-F32-QUANTIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-SAMPLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEYS.
    05 FILLER PIC X(112) VALUE "minecraft:overworld/temperature".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/vegetation".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/continents".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/erosion".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/depth".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/ridges".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(112) OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-QY                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-TARGET.
    05 L-T                 BINARY-DOUBLE OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-QX L-QY L-QZ L-TARGET.
     COMPUTE WS-X = L-QX * 4
     COMPUTE WS-Y = L-QY * 4
     COMPUTE WS-Z = L-QZ * 4
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "DENSITY-EVAL" USING WS-KEY(WS-I) WS-X WS-Y WS-Z WS-V
         CALL "CLIMATE-F32-QUANTIZE" USING WS-V L-T(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM CLIMATE-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-POINTS-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 PROCEDURE DIVISION.
     MOVE 0 TO CL-COUNT
     CALL "CLIMATE-MEMO-RESET"
     GOBACK.
 END PROGRAM CLIMATE-POINTS-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-MEMO-RESET.
*> No parameters: forgets every biome the memo of CLIMATE-BIOME-AT holds (the generation rises: no entry carries it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 PROCEDURE DIVISION.
     ADD 1 TO CM-GEN
     GOBACK.
 END PROGRAM CLIMATE-MEMO-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-POINT-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                PIC X(40).
 01 L-MINS.
    05 L-MIN               BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-MAXS.
    05 L-MAX               BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-OFFSET               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-BIOME L-MINS L-MAXS L-OFFSET.
     CALL "CLIMATE-MEMO-RESET"
     ADD 1 TO CL-COUNT
     MOVE L-BIOME TO CL-BIOME(CL-COUNT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE L-MIN(WS-I) TO CL-MIN(CL-COUNT, WS-I)
         MOVE L-MAX(WS-I) TO CL-MAX(CL-COUNT, WS-I)
     END-PERFORM
     MOVE L-OFFSET TO CL-OFFSET(CL-COUNT)
     GOBACK.
 END PROGRAM CLIMATE-POINT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-POINTS-LOAD.
*> The Nether preset (10 7.2 as 37 part 3 section 2): every parameter is a point interval, the seventh value the offset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 7 TIMES.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-PRESET               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PRESET L-COUNT.
     CALL "CLIMATE-POINTS-RESET"
     CALL "BIOME-SOURCE-POINT-COUNT" USING L-PRESET L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "BIOME-SOURCE-POINT" USING L-PRESET WS-I WS-BIOME WS-VALUES
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-VALUE(WS-K) TO WS-MIN(WS-K)
         END-PERFORM
         MOVE WS-VALUE(7) TO WS-OFFSET
         MOVE WS-MINS TO WS-MAXS
         CALL "CLIMATE-POINT-ADD" USING WS-BIOME WS-MINS WS-MAXS WS-OFFSET
     END-PERFORM
     GOBACK.
 END PROGRAM CLIMATE-POINTS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-FITNESS.
*> USING target (6 BINARY-DOUBLE), point (BINARY-LONG), best index (0 for none), best fitness (BINARY-DOUBLE), fitness out, k out:
*> the squared distance of the target to the point (the offset squared plus the squared distance to each of the six intervals).
*> With a best, the sum stops as soon as it exceeds the best fitness, or equals it for a point of a larger index than the best
*> (it only grows); k out is above 6 when every parameter was added.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 01 WS-D                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TARGET.
    05 L-T                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-I                    BINARY-LONG.
 01 L-BEST                 BINARY-LONG.
 01 L-BEST-F               BINARY-DOUBLE.
 01 L-F                    BINARY-DOUBLE.
 01 L-K                    BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGET L-I L-BEST L-BEST-F L-F L-K.
     COMPUTE L-F = CL-OFFSET(L-I) * CL-OFFSET(L-I)
     PERFORM VARYING L-K FROM 1 BY 1 UNTIL L-K > 6 OR (L-BEST > 0 AND (L-F > L-BEST-F OR (L-F = L-BEST-F AND L-I > L-BEST)))
         EVALUATE TRUE
             WHEN L-T(L-K) > CL-MAX(L-I, L-K)
                 COMPUTE WS-D = L-T(L-K) - CL-MAX(L-I, L-K)
             WHEN L-T(L-K) < CL-MIN(L-I, L-K)
                 COMPUTE WS-D = CL-MIN(L-I, L-K) - L-T(L-K)
             WHEN OTHER
                 MOVE 0 TO WS-D
         END-EVALUATE
         COMPUTE L-F = L-F + WS-D * WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM CLIMATE-FITNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-FIND.
*> The first point of the smallest fitness, the same answer as a scan of every point in order (a point wins over the best so far
*> when its fitness is smaller, or equal with a smaller index). Three things make it cheap:
*>  - the points are grouped by their intervals of temperature, humidity and depth (a few hundred groups for the overworld list; built
*>    on the first lookup after the points or the seed changed), and a group whose lower bound (the squared distances in those three
*>    parameters plus the smallest squared offset of its members) exceeds the best so far is skipped whole;
*>  - the best starts as the winner of the previous lookup (neighbouring cells have near climates), evaluated in full first;
*>  - a point is dropped as soon as its partial sum exceeds the best (CLIMATE-FITNESS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 01 WS-LAST                BINARY-LONG VALUE 0.
 01 WS-BUILT               BINARY-LONG VALUE -1.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-GROUP-TABLE.
    05 WS-GROUP OCCURS 8192 TIMES.
       10 WS-G-MIN         BINARY-DOUBLE OCCURS 3 TIMES.
       10 WS-G-MAX         BINARY-DOUBLE OCCURS 3 TIMES.
       10 WS-G-OFF         BINARY-DOUBLE.
       10 WS-G-START       BINARY-LONG.
       10 WS-G-COUNT       BINARY-LONG.
 01 WS-MEMBER-TABLE.
    05 WS-MEMBER           BINARY-LONG OCCURS 8192 TIMES.
 01 WS-OF-POINT-TABLE.
    05 WS-OF-POINT         BINARY-LONG OCCURS 8192 TIMES.
 01 WS-DIM-LIST.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 5.
 01 WS-DIMS REDEFINES WS-DIM-LIST.
    05 WS-DIM              BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-F                   BINARY-DOUBLE.
 01 WS-LB                  BINARY-DOUBLE.
 01 WS-OFF2                BINARY-DOUBLE.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-F              BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TARGET.
    05 L-T                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-INDEX                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 01 L-FITNESS              BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TARGET L-INDEX L-BIOME L-FITNESS.
     MOVE 0 TO L-INDEX
     MOVE SPACES TO L-BIOME
     MOVE 0 TO L-FITNESS
     MOVE 0 TO WS-BEST WS-BEST-F
     IF WS-BUILT NOT = CM-GEN
*>       groups the points by the intervals of the three parameters, the members of a group in point order
         MOVE 0 TO WS-GROUPS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
             COMPUTE WS-OFF2 = CL-OFFSET(WS-I) * CL-OFFSET(WS-I)
             MOVE 0 TO WS-J
             PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > WS-GROUPS OR WS-J > 0
                 MOVE 1 TO WS-SAME
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     IF CL-MIN(WS-I, WS-DIM(WS-K)) NOT = WS-G-MIN(WS-G, WS-K) OR CL-MAX(WS-I, WS-DIM(WS-K)) NOT = WS-G-MAX(WS-G, WS-K)
                         MOVE 0 TO WS-SAME
                     END-IF
                 END-PERFORM
                 IF WS-SAME = 1
                     MOVE WS-G TO WS-J
                 END-IF
             END-PERFORM
             IF WS-J = 0
                 ADD 1 TO WS-GROUPS
                 MOVE WS-GROUPS TO WS-J
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     MOVE CL-MIN(WS-I, WS-DIM(WS-K)) TO WS-G-MIN(WS-J, WS-K)
                     MOVE CL-MAX(WS-I, WS-DIM(WS-K)) TO WS-G-MAX(WS-J, WS-K)
                 END-PERFORM
                 MOVE WS-OFF2 TO WS-G-OFF(WS-J)
                 MOVE 0 TO WS-G-COUNT(WS-J)
             END-IF
             IF WS-OFF2 < WS-G-OFF(WS-J)
                 MOVE WS-OFF2 TO WS-G-OFF(WS-J)
             END-IF
             ADD 1 TO WS-G-COUNT(WS-J)
             MOVE WS-J TO WS-OF-POINT(WS-I)
         END-PERFORM
         MOVE 1 TO WS-M
         PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > WS-GROUPS
             MOVE WS-M TO WS-G-START(WS-G)
             ADD WS-G-COUNT(WS-G) TO WS-M
             MOVE 0 TO WS-G-COUNT(WS-G)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
             MOVE WS-OF-POINT(WS-I) TO WS-G
             COMPUTE WS-M = WS-G-START(WS-G) + WS-G-COUNT(WS-G)
             MOVE WS-I TO WS-MEMBER(WS-M)
             ADD 1 TO WS-G-COUNT(WS-G)
         END-PERFORM
         MOVE CM-GEN TO WS-BUILT
     END-IF
     IF WS-LAST > 0 AND WS-LAST <= CL-COUNT
         CALL "CLIMATE-FITNESS" USING L-TARGET WS-LAST WS-BEST WS-BEST-F WS-F WS-K
         MOVE WS-LAST TO WS-BEST
         MOVE WS-F TO WS-BEST-F
     END-IF
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > WS-GROUPS
*>       WS-LB: a lower bound of the fitness of every member of the group
         MOVE WS-G-OFF(WS-G) TO WS-LB
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             EVALUATE TRUE
                 WHEN L-T(WS-DIM(WS-K)) > WS-G-MAX(WS-G, WS-K)
                     COMPUTE WS-D = L-T(WS-DIM(WS-K)) - WS-G-MAX(WS-G, WS-K)
                 WHEN L-T(WS-DIM(WS-K)) < WS-G-MIN(WS-G, WS-K)
                     COMPUTE WS-D = WS-G-MIN(WS-G, WS-K) - L-T(WS-DIM(WS-K))
                 WHEN OTHER
                     MOVE 0 TO WS-D
             END-EVALUATE
             COMPUTE WS-LB = WS-LB + WS-D * WS-D
         END-PERFORM
         IF WS-BEST = 0 OR WS-LB NOT > WS-BEST-F
             PERFORM VARYING WS-M FROM WS-G-START(WS-G) BY 1 UNTIL WS-M >= WS-G-START(WS-G) + WS-G-COUNT(WS-G)
                 MOVE WS-MEMBER(WS-M) TO WS-I
                 CALL "CLIMATE-FITNESS" USING L-TARGET WS-I WS-BEST WS-BEST-F WS-F WS-K
                 IF WS-K > 6 AND (WS-BEST = 0 OR WS-F < WS-BEST-F OR (WS-F = WS-BEST-F AND WS-I < WS-BEST))
                     MOVE WS-I TO WS-BEST
                     MOVE WS-F TO WS-BEST-F
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE WS-BEST TO L-INDEX WS-LAST
         MOVE CL-BIOME(WS-BEST) TO L-BIOME
         MOVE WS-BEST-F TO L-FITNESS
     END-IF
     GOBACK.
 END PROGRAM CLIMATE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-BIOME-AT.
*> USING qx, qy, qz, index out, biome out: the sample and the lookup of the cell, read from the memo when the cell is in it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-FITNESS             BINARY-DOUBLE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-QY                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 PROCEDURE DIVISION USING L-QX L-QY L-QZ L-INDEX L-BIOME.
     COMPUTE WS-HASH = L-QX * 73 + L-QZ * 1031 + L-QY * 7919
     COMPUTE WS-SLOT = FUNCTION MOD(WS-HASH, CM-SIZE) + 1
     IF CM-STAMP(WS-SLOT) = CM-GEN + 1 AND CM-QX(WS-SLOT) = L-QX AND CM-QY(WS-SLOT) = L-QY AND CM-QZ(WS-SLOT) = L-QZ
         MOVE CM-INDEX(WS-SLOT) TO L-INDEX
         MOVE CM-BIOME(WS-SLOT) TO L-BIOME
         GOBACK
     END-IF
     CALL "CLIMATE-SAMPLE" USING L-QX L-QY L-QZ WS-TARGET
     CALL "CLIMATE-FIND" USING WS-TARGET L-INDEX L-BIOME WS-FITNESS
     COMPUTE CM-STAMP(WS-SLOT) = CM-GEN + 1
     MOVE L-QX TO CM-QX(WS-SLOT)
     MOVE L-QY TO CM-QY(WS-SLOT)
     MOVE L-QZ TO CM-QZ(WS-SLOT)
     MOVE L-INDEX TO CM-INDEX(WS-SLOT)
     MOVE L-BIOME TO CM-BIOME(WS-SLOT)
     GOBACK.
 END PROGRAM CLIMATE-BIOME-AT.
