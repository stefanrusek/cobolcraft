*> The shared facts of the water and surface features (docs/protocol/35-worldgen-features-5-water-and-surface.md sections 1 and 2): the block-write flags (1.1), the iteration orders and random helpers
*> (1.2) as small programs over a java.util.Random state (rng-java.cob), and the configuration limits of the class table (2.1).
*> Entry points:
*>   F355-FLAG USING kind (1 setBlock(pos, state, 2), 2 Feature.setBlock = setBlockAndUpdate, 3 block piles' UPDATE_NONE), flags out (2, 3, 260)
*>   F355-BETWEEN USING x0, y0, z0, x1, y1, z1 (the corners in any order), index (0-based), x, y, z out: the index-th position of betweenClosed (x fastest, then y, z slowest, both ends inclusive)
*>   F355-MANHATTAN-IN USING dx, dy, dz, rx, ry, rz, flag out: the offset is in the box of withinBoxByManhattanDistance (each |d| at most its radius and the Manhattan distance at most the sum)
*>   F355-SHUFFLE USING table (BINARY-LONG items), size, state: Util.shuffle (for i = size down to 2: j = nextInt(i), swap the items i - 1 and j, 0-based)
*>   F355-WEIGHTED USING table of weights, size, state, index out: WeightedList.getRandom (nextInt(total), the first entry where the running value becomes negative; 0 and no draw for a total of 0)
*>   F355-TRAPEZOID USING max, state, value out: trapezoid(-max, max, 0) = nextInt(max + 1) - nextInt(max + 1)
*>   F355-LIMITS USING name (PIC X(48), type.field), lo out, hi out, default out (-1 when none), found out: the numeric limits and defaults of 2.1 (a plain int with no stated range has hi 2147483647)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-FLAG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FLAGS.
     EVALUATE L-KIND
         WHEN 1
             MOVE 2 TO L-FLAGS
         WHEN 2
             MOVE 3 TO L-FLAGS
         WHEN OTHER
             MOVE 260 TO L-FLAGS
     END-EVALUATE
     GOBACK.
 END PROGRAM F355-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-BETWEEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-MAX-X               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-INDEX L-X L-Y L-Z.
     MOVE FUNCTION MIN(L-X0, L-X1) TO WS-MIN-X
     MOVE FUNCTION MIN(L-Y0, L-Y1) TO WS-MIN-Y
     MOVE FUNCTION MIN(L-Z0, L-Z1) TO WS-MIN-Z
     MOVE FUNCTION MAX(L-X0, L-X1) TO WS-MAX-X
     MOVE FUNCTION MAX(L-Y0, L-Y1) TO WS-MAX-Y
     COMPUTE WS-W = WS-MAX-X - WS-MIN-X + 1
     COMPUTE WS-H = WS-MAX-Y - WS-MIN-Y + 1
     COMPUTE L-X = WS-MIN-X + FUNCTION MOD(L-INDEX, WS-W)
     DIVIDE L-INDEX BY WS-W GIVING WS-Q
     COMPUTE L-Y = WS-MIN-Y + FUNCTION MOD(WS-Q, WS-H)
     DIVIDE WS-Q BY WS-H GIVING WS-Q
     COMPUTE L-Z = WS-MIN-Z + WS-Q
     GOBACK.
 END PROGRAM F355-BETWEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-MANHATTAN-IN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-RX L-RY L-RZ L-FLAG.
     MOVE 0 TO L-FLAG
     IF FUNCTION ABS(L-DX) <= L-RX AND FUNCTION ABS(L-DY) <= L-RY AND FUNCTION ABS(L-DZ) <= L-RZ
         IF FUNCTION ABS(L-DX) + FUNCTION ABS(L-DY) + FUNCTION ABS(L-DZ) <= L-RX + L-RY + L-RZ
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F355-MANHATTAN-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-SHUFFLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-VIEW                BASED.
    05 L-ITEM              BINARY-LONG OCCURS 1024 TIMES.
 LINKAGE SECTION.
 01 L-TABLE                PIC X.
 01 L-SIZE                 BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-TABLE L-SIZE L-STATE.
     SET ADDRESS OF WS-VIEW TO ADDRESS OF L-TABLE
     PERFORM VARYING WS-I FROM L-SIZE BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-I WS-DRAW
         COMPUTE WS-J = WS-DRAW + 1
         MOVE L-ITEM(WS-I) TO WS-HOLD
         MOVE L-ITEM(WS-J) TO L-ITEM(WS-I)
         MOVE WS-HOLD TO L-ITEM(WS-J)
     END-PERFORM
     GOBACK.
 END PROGRAM F355-SHUFFLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-WEIGHTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-VIEW                BASED.
    05 L-WEIGHT            BINARY-LONG OCCURS 1024 TIMES.
 LINKAGE SECTION.
 01 L-TABLE                PIC X.
 01 L-SIZE                 BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-TABLE L-SIZE L-STATE L-INDEX.
     SET ADDRESS OF WS-VIEW TO ADDRESS OF L-TABLE
     MOVE 0 TO L-INDEX WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-SIZE
         ADD L-WEIGHT(WS-I) TO WS-TOTAL
     END-PERFORM
     IF WS-TOTAL = 0
         GOBACK
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-TOTAL WS-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-SIZE OR L-INDEX > 0
         SUBTRACT L-WEIGHT(WS-I) FROM WS-V
         IF WS-V < 0
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F355-WEIGHTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-TRAPEZOID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-STATE L-VALUE.
     COMPUTE WS-BOUND = L-MAX + 1
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-A
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-B
     COMPUTE L-VALUE = WS-A - WS-B
     GOBACK.
 END PROGRAM F355-TRAPEZOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-LIMITS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(48) VALUE "disk.radius".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 8.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "disk.half_height".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 4.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs.radius".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 12.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "fill_layer.height".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 384.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "underwater_magma.floor_search_range".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 512.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "underwater_magma.placement_radius_around_floor".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 64.
    05 FILLER PIC S9(10) VALUE -1.
    05 FILLER PIC X(48) VALUE "spring_feature.rock_count".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 2147483647.
    05 FILLER PIC S9(10) VALUE 4.
    05 FILLER PIC X(48) VALUE "spring_feature.hole_count".
    05 FILLER PIC S9(10) VALUE 0.
    05 FILLER PIC S9(10) VALUE 2147483647.
    05 FILLER PIC S9(10) VALUE 1.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 8 TIMES.
       10 WS-NAME          PIC X(48).
       10 WS-LO            PIC S9(10).
       10 WS-HI            PIC S9(10).
       10 WS-DEFAULT       PIC S9(10).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-LO                   BINARY-LONG.
 01 L-HI                   BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LO L-HI L-DEFAULT L-FOUND.
     MOVE 0 TO L-FOUND L-LO L-HI
     MOVE -1 TO L-DEFAULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         IF WS-NAME(WS-I) = L-NAME
             MOVE 1 TO L-FOUND
             MOVE WS-LO(WS-I) TO L-LO
             MOVE WS-HI(WS-I) TO L-HI
             MOVE WS-DEFAULT(WS-I) TO L-DEFAULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F355-LIMITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-RUNS-IN.
*> USING key (PIC X(80), the placed feature id without the namespace), step (0 to 10), count out: section 19, the number of biomes of the loaded worldgen store (function kind 7) that list the placed
*> feature in that decoration step (a biome lists a feature once per step); 0 for a step outside 0 to 10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FULL                PIC X(160).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-STEP                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STEP L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE SPACES TO WS-FULL
     STRING "minecraft:" FUNCTION TRIM(L-KEY TRAILING) DELIMITED BY SIZE INTO WS-FULL
     IF L-STEP >= 0 AND L-STEP <= 10
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(4)
             IF WGF-KIND(WS-I) = 7
                 MOVE 0 TO WS-FOUND
                 MOVE WGN-CHILD(WGF-ROOT(WS-I), 1) TO WS-NODE
                 PERFORM UNTIL WS-NODE = 0
                     IF WGN-INT(WS-NODE, 1) = L-STEP AND WGN-TEXT-1(WS-NODE) = WS-FULL
                         MOVE 1 TO WS-FOUND
                     END-IF
                     MOVE WGN-NEXT(WS-NODE) TO WS-NODE
                 END-PERFORM
                 ADD WS-FOUND TO L-COUNT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM F355-RUNS-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F355-BIOME-HAS.
*> USING biome (PIC X(80), the biome id without the namespace), key (PIC X(80), a placed feature id without the namespace), step, flag out: 1 when the biome's feature lists name the placed feature in
*> that step (section 19); 0 for another step or a biome that is not loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-FULL                PIC X(160).
 01 WS-BIOME-FULL          PIC X(112).
 LINKAGE SECTION.
 01 L-BIOME                PIC X(80).
 01 L-KEY                  PIC X(80).
 01 L-STEP                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-KEY L-STEP L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE SPACES TO WS-FULL WS-BIOME-FULL
     STRING "minecraft:" FUNCTION TRIM(L-KEY TRAILING) DELIMITED BY SIZE INTO WS-FULL
     STRING "minecraft:" FUNCTION TRIM(L-BIOME TRAILING) DELIMITED BY SIZE INTO WS-BIOME-FULL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(4)
         IF WGF-KIND(WS-I) = 7 AND WGF-KEY(WS-I) = WS-BIOME-FULL
             MOVE WGN-CHILD(WGF-ROOT(WS-I), 1) TO WS-NODE
             PERFORM UNTIL WS-NODE = 0
                 IF WGN-INT(WS-NODE, 1) = L-STEP AND WGN-TEXT-1(WS-NODE) = WS-FULL
                     MOVE 1 TO L-FLAG
                 END-IF
                 MOVE WGN-NEXT(WS-NODE) TO WS-NODE
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F355-BIOME-HAS.
