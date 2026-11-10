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
     GOBACK.
 END PROGRAM CLIMATE-POINTS-RESET.

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
 PROGRAM-ID. CLIMATE-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLIMATE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-F                   BINARY-DOUBLE.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
         COMPUTE WS-F = CL-OFFSET(WS-I) * CL-OFFSET(WS-I)
*>       the sum only grows: a point already no better than the best so far cannot win (a tie keeps the earlier point)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR (L-INDEX > 0 AND WS-F >= L-FITNESS)
             EVALUATE TRUE
                 WHEN L-T(WS-K) > CL-MAX(WS-I, WS-K)
                     COMPUTE WS-D = L-T(WS-K) - CL-MAX(WS-I, WS-K)
                 WHEN L-T(WS-K) < CL-MIN(WS-I, WS-K)
                     COMPUTE WS-D = CL-MIN(WS-I, WS-K) - L-T(WS-K)
                 WHEN OTHER
                     MOVE 0 TO WS-D
             END-EVALUATE
             COMPUTE WS-F = WS-F + WS-D * WS-D
         END-PERFORM
         IF L-INDEX = 0 OR (WS-K > 6 AND WS-F < L-FITNESS)
             MOVE WS-I TO L-INDEX
             MOVE CL-BIOME(WS-I) TO L-BIOME
             MOVE WS-F TO L-FITNESS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CLIMATE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIMATE-BIOME-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-FITNESS             BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-QY                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 PROCEDURE DIVISION USING L-QX L-QY L-QZ L-INDEX L-BIOME.
     CALL "CLIMATE-SAMPLE" USING L-QX L-QY L-QZ WS-TARGET
     CALL "CLIMATE-FIND" USING WS-TARGET L-INDEX L-BIOME WS-FITNESS
     GOBACK.
 END PROGRAM CLIMATE-BIOME-AT.
