*> The large dripstone feature (docs/protocol/35-worldgen-features-6-underground.md section 7; registry id 26, large_dripstone): FD-DRIP-NODE compiles the configuration into a row of FD-WA:
*> WA-I(1) the block index of dripstone_block (the base block is hard-wired), WA-START(1) and WA-N(1) the pool of replaceable_blocks, WA-START(2) and WA-N(2) the pool of the tag
*> base_stone_overworld (the blocks that stop a column), WA-I(2) floor_to_ceiling_search_range (30), WA-I(3) and WA-I(4) the minimum and maximum of column_radius (the provider is never sampled),
*> WA-I(5) to WA-I(8) the kinds and WA-G(1 .. 8) the two values each of the float providers height_scale, stalactite_bluntness, stalagmite_bluntness and wind_speed (constant or uniform; FD-FP),
*> WA-F(1) max_column_radius_to_cave_height_ratio, WA-F(2) min_bluntness_for_wind, WA-I(9) min_radius_for_wind. A missing or unsupported member makes the feature unsupported.
*> FR-DRIP places it (7.4): the cave column scan, the radius draw, the two speleothem objects (stalactite first; each draws its bluntness then the height scale), the wind (both objects suitable:
*> wind_speed and phi), the moves back into the stone (7.5, no draws) and the columns of blocks (7.6: one nextFloat per column of positive height, a second when it is below 0.2). Single precision
*> steps use FX-OP (every Java float operation rounded to binary32), the double steps cc_f64_*, Mth.cos and Mth.sin the shim's table functions. The heightmap limit of a stalagmite column is the
*> WORLD_SURFACE_WG height of the level (FL-HEIGHT-OF, read from the cells at that moment). Every write has flag 2. The debug markers are not made.
*>
*> Entry points: FD-DRIP-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-DRIP USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-DRIP-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY FDCONST.
 01 WS-K-SET               PIC X(40) VALUE "replaceable_blocks".
 01 WS-K-RANGE             PIC X(40) VALUE "floor_to_ceiling_search_range".
 01 WS-K-RADIUS            PIC X(40) VALUE "column_radius".
 01 WS-K-SCALE             PIC X(40) VALUE "height_scale".
 01 WS-K-RATIO             PIC X(40) VALUE "max_column_radius_to_cave_height_ratio".
 01 WS-K-BLUNT-A           PIC X(40) VALUE "stalactite_bluntness".
 01 WS-K-BLUNT-B           PIC X(40) VALUE "stalagmite_bluntness".
 01 WS-K-WIND              PIC X(40) VALUE "wind_speed".
 01 WS-K-WIND-R            PIC X(40) VALUE "min_radius_for_wind".
 01 WS-K-WIND-B            PIC X(40) VALUE "min_bluntness_for_wind".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:base_stone_overworld".
 01 WS-NAME                PIC X(48) VALUE "minecraft:dripstone_block".
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUES.
    05 WS-VAL              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-IP.
    05 WS-IPV              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 1)
     IF WA-I(WS-ROW, 1) = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SET WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 1) WA-N(WS-ROW, 1)
     COMPUTE WA-START(WS-ROW, 2) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG WA-N(WS-ROW, 2)
*>   the search range (default 30, 1 to 512)
     MOVE 30 TO WA-I(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RANGE WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 2) WS-OK
         IF WS-OK = 0 OR WA-I(WS-ROW, 2) < 1 OR WA-I(WS-ROW, 2) > 512
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
*>   column_radius: only the bounds matter (a constant gives both)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RADIUS WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WS-IP WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     ELSE
         IF WS-IPV(1) = 1
             MOVE WS-IPV(2) TO WA-I(WS-ROW, 3)
             MOVE WS-IPV(2) TO WA-I(WS-ROW, 4)
         ELSE
             MOVE WS-IPV(2) TO WA-I(WS-ROW, 3)
             MOVE WS-IPV(3) TO WA-I(WS-ROW, 4)
         END-IF
         IF WA-I(WS-ROW, 3) < 1 OR WA-I(WS-ROW, 4) < WA-I(WS-ROW, 3)
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SCALE WS-E
     PERFORM FLOAT-PROVIDER-1
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLUNT-A WS-E
     PERFORM FLOAT-PROVIDER-2
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLUNT-B WS-E
     PERFORM FLOAT-PROVIDER-3
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-WIND WS-E
     PERFORM FLOAT-PROVIDER-4
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RATIO WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-WIND-B WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-WIND-R WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 9) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GO TO MAIN-EXIT.
*> FLOAT-PROVIDER-n: the float provider of node WS-E into WA-I(4 + n) and WA-G(2 n - 1 .. 2 n); only constants and uniform providers are kept
 FLOAT-PROVIDER-1.
     MOVE 5 TO WS-I
     PERFORM FLOAT-PROVIDER
     .
 FLOAT-PROVIDER-2.
     MOVE 6 TO WS-I
     PERFORM FLOAT-PROVIDER
     .
 FLOAT-PROVIDER-3.
     MOVE 7 TO WS-I
     PERFORM FLOAT-PROVIDER
     .
 FLOAT-PROVIDER-4.
     MOVE 8 TO WS-I
     PERFORM FLOAT-PROVIDER
     .
 FLOAT-PROVIDER.
     CALL "FD-FP" USING JSON-DOC WS-E WS-KIND WS-VALUES WS-OK
     IF WS-OK = 0 OR WS-KIND > 2
         MOVE 1 TO FD-BAD
         MOVE 1 TO WS-KIND
     END-IF
     MOVE WS-KIND TO WA-I(WS-ROW, WS-I)
     COMPUTE WS-E = (WS-I - 5) * 2 + 1
     MOVE WS-VAL(1) TO WA-G(WS-ROW, WS-E)
     MOVE WS-VAL(2) TO WA-G(WS-ROW, WS-E + 1)
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FD-DRIP-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DRIP.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CEILING             BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-HAVE-CEILING        BINARY-LONG.
 01 WS-HAVE-FLOOR          BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-MAXR                BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
*> the two objects: 1 stalactite (root at the ceiling, points down), 2 stalagmite (root at the floor, points up)
 01 WS-S                   BINARY-LONG.
 01 WS-OBJ.
    05 WS-O OCCURS 2 TIMES.
       10 WS-ORX           BINARY-LONG.
       10 WS-ORY           BINARY-LONG.
       10 WS-ORZ           BINARY-LONG.
       10 WS-ORAD          BINARY-LONG.
       10 WS-OBLUNT        FLOAT-LONG.
       10 WS-OSCALE        FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUES.
    05 WS-VAL              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-F4                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-D4                  FLOAT-LONG.
 01 WS-D5                  FLOAT-LONG.
 01 WS-SG                  BINARY-LONG.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
*> the double constants of the height function and the float constants
 01 WS-C0384               FLOAT-LONG.
 01 WS-C075                FLOAT-LONG.
 01 WS-C43                 FLOAT-LONG.
 01 WS-C23                 FLOAT-LONG.
 01 WS-C13                 FLOAT-LONG.
 01 WS-C6                  FLOAT-LONG VALUE 6.0.
 01 WS-C-TWO-PI            FLOAT-LONG.
 01 WS-C-PI                FLOAT-LONG.
 01 WS-C-ZERO              FLOAT-LONG VALUE 0.
 01 WS-C-02                FLOAT-LONG.
 01 WS-C-08                FLOAT-LONG.
 01 WS-C-10                FLOAT-LONG VALUE 1.0.
 01 WS-LIT-02              FLOAT-LONG VALUE 0.2.
 01 WS-LIT-08              FLOAT-LONG VALUE 0.8.
*> height function work
 01 WS-HD                  FLOAT-LONG.
 01 WS-HRADIUS             FLOAT-LONG.
 01 WS-HT                  FLOAT-LONG.
 01 WS-HA                  FLOAT-LONG.
 01 WS-HB                  FLOAT-LONG.
 01 WS-HC                  FLOAT-LONG.
 01 WS-HV                  FLOAT-LONG.
 01 WS-HOUT                BINARY-LONG.
*> wind
 01 WS-WIND                BINARY-LONG.
 01 WS-WIND-X              FLOAT-LONG.
 01 WS-WIND-Z              FLOAT-LONG.
 01 WS-ORIGIN-Y            BINARY-LONG.
 01 WS-MAX-OFF             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-OFX                 BINARY-LONG.
 01 WS-OFZ                 BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DYD                 FLOAT-LONG.
 01 WS-NEG-OFF             BINARY-LONG.
*> moveBack and the embedded test
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MCX                 BINARY-LONG.
 01 WS-MCY                 BINARY-LONG.
 01 WS-MCZ                 BINARY-LONG.
 01 WS-EMB                 BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-RADF                FLOAT-LONG.
 01 WS-COSV                FLOAT-LONG.
 01 WS-SINV                FLOAT-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-OKA                 BINARY-LONG.
 01 WS-OKB                 BINARY-LONG.
*> placeBlocks
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NR                  BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-LIM-STATE           BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-SQ                  BINARY-LONG.
 01 WS-SQD                 FLOAT-LONG.
 01 WS-FH                  FLOAT-LONG.
 01 WS-ORD0                BINARY-LONG VALUE 0.
 01 WS-DRIP-STATE          BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.384" WS-C0384
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.75" WS-C075
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"1.3333333333333333" WS-C43
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.6666666666666666" WS-C23
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.3333333333333333" WS-C13
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"6.2831855" WS-D1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D1 WS-C-TWO-PI
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"3.1415927" WS-D1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D1 WS-C-PI
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIT-02 WS-C-02
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIT-08 WS-C-08
*>   1. the origin must be air or water
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
*>   2. Column.scan: up, then down; the scan ends on the first block that is not air or water, which must be dripstone or in the replaceable set (or lava)
     MOVE 0 TO WS-HAVE-CEILING WS-HAVE-FLOOR
     MOVE L-X TO WS-CX
     MOVE L-Y TO WS-CY
     MOVE L-Z TO WS-CZ
     MOVE 1 TO WS-STEPS
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-STEPS >= WA-I(WS-ROW, 2) OR WS-MORE = 0
         CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
         CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
         IF WS-FLAG = 1
             ADD 1 TO WS-CY
             ADD 1 TO WS-STEPS
         ELSE
             MOVE 0 TO WS-MORE
         END-IF
     END-PERFORM
     CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
     PERFORM IS-BASE-OR-LAVA
     IF WS-FLAG = 1
         MOVE 1 TO WS-HAVE-CEILING
         MOVE WS-CY TO WS-CEILING
     END-IF
     MOVE L-Y TO WS-CY
     MOVE 1 TO WS-STEPS
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-STEPS >= WA-I(WS-ROW, 2) OR WS-MORE = 0
         CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
         CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
         IF WS-FLAG = 1
             SUBTRACT 1 FROM WS-CY
             ADD 1 TO WS-STEPS
         ELSE
             MOVE 0 TO WS-MORE
         END-IF
     END-PERFORM
     CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
     PERFORM IS-BASE-OR-LAVA
     IF WS-FLAG = 1
         MOVE 1 TO WS-HAVE-FLOOR
         MOVE WS-CY TO WS-FLOOR
     END-IF
     IF WS-HAVE-CEILING = 0 OR WS-HAVE-FLOOR = 0
         GOBACK
     END-IF
     COMPUTE WS-HEIGHT = WS-CEILING - WS-FLOOR - 1
     IF WS-HEIGHT < 4
         GOBACK
     END-IF
*>   4. the radius
     MOVE WS-HEIGHT TO WS-D1
     MOVE WA-F(WS-ROW, 1) TO WS-D2
     CALL "FR-F32" USING WS-D2
     CALL "FX-OP" USING WS-OP-MUL WS-D1 WS-D2 WS-D3
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D3 WS-MAXR
     IF WS-MAXR < WA-I(WS-ROW, 3)
         MOVE WA-I(WS-ROW, 3) TO WS-MAXR
     END-IF
     IF WS-MAXR > WA-I(WS-ROW, 4)
         MOVE WA-I(WS-ROW, 4) TO WS-MAXR
     END-IF
     COMPUTE WS-BOUND = WS-MAXR - WA-I(WS-ROW, 3) + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
     COMPUTE WS-RADIUS = WS-DRAW + WA-I(WS-ROW, 3)
*>   5. the objects: the stalactite first, then the stalagmite
     MOVE L-X TO WS-ORX(1)
     COMPUTE WS-ORY(1) = WS-CEILING - 1
     MOVE L-Z TO WS-ORZ(1)
     MOVE WS-RADIUS TO WS-ORAD(1)
     PERFORM SAMPLE-BLUNT-A
     PERFORM SAMPLE-SCALE
     MOVE L-X TO WS-ORX(2)
     COMPUTE WS-ORY(2) = WS-FLOOR + 1
     MOVE L-Z TO WS-ORZ(2)
     MOVE WS-RADIUS TO WS-ORAD(2)
     PERFORM SAMPLE-BLUNT-B
     PERFORM SAMPLE-SCALE-2
*>   6. the wind
     MOVE 0 TO WS-WIND
     MOVE 1 TO WS-S
     PERFORM WIND-SUITABLE
     MOVE WS-FLAG TO WS-OKA
     MOVE 2 TO WS-S
     PERFORM WIND-SUITABLE
     IF WS-OKA = 1 AND WS-FLAG = 1
         MOVE 1 TO WS-WIND
         MOVE WA-I(WS-ROW, 8) TO WS-KIND
         MOVE WA-G(WS-ROW, 7) TO WS-VAL(1)
         MOVE WA-G(WS-ROW, 8) TO WS-VAL(2)
         CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-F1
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F2
         CALL "FX-OP" USING WS-OP-SUB WS-C-PI WS-C-ZERO WS-D1
         CALL "FX-OP" USING WS-OP-MUL WS-F2 WS-D1 WS-D2
         CALL "FX-OP" USING WS-OP-ADD WS-D2 WS-C-ZERO WS-F2
*>       the wind vector: (cos(phi) * s, 0, sin(phi) * s), each product a float
         CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE WS-F2 WS-COSV
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-F2 WS-SINV
         CALL "FX-OP" USING WS-OP-MUL WS-COSV WS-F1 WS-WIND-X
         CALL "FX-OP" USING WS-OP-MUL WS-SINV WS-F1 WS-WIND-Z
         MOVE L-Y TO WS-ORIGIN-Y
         COMPUTE WS-MAX-OFF = 16 - WS-RADIUS
         COMPUTE WS-NEG-OFF = 0 - WS-MAX-OFF
     END-IF
*>   7. and 8. move back (the stalactite first), then place what could be moved
     MOVE 1 TO WS-S
     PERFORM MOVE-BACK
     MOVE WS-OK TO WS-OKA
     MOVE 2 TO WS-S
     PERFORM MOVE-BACK
     MOVE WS-OK TO WS-OKB
     IF WS-OKA = 1
         MOVE 1 TO WS-S
         PERFORM PLACE-BLOCKS
     END-IF
     IF WS-OKB = 1
         MOVE 2 TO WS-S
         PERFORM PLACE-BLOCKS
     END-IF
     MOVE 1 TO L-RESULT
     GO TO MAIN-EXIT.
*> IS-BASE-OR-LAVA: WS-FLAG 1 when WS-STATE is dripstone_block, in the replaceable set or lava
 IS-BASE-OR-LAVA.
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-FLAG
     IF WS-CLASS = 3 OR WS-BLOCK = WA-I(WS-ROW, 1)
         MOVE 1 TO WS-FLAG
     ELSE
         CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-FLAG
     END-IF
     .
 SAMPLE-BLUNT-A.
     MOVE WA-I(WS-ROW, 6) TO WS-KIND
     MOVE WA-G(WS-ROW, 3) TO WS-VAL(1)
     MOVE WA-G(WS-ROW, 4) TO WS-VAL(2)
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-OBLUNT(1)
     .
 SAMPLE-SCALE.
     MOVE WA-I(WS-ROW, 5) TO WS-KIND
     MOVE WA-G(WS-ROW, 1) TO WS-VAL(1)
     MOVE WA-G(WS-ROW, 2) TO WS-VAL(2)
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-OSCALE(1)
     .
 SAMPLE-BLUNT-B.
     MOVE WA-I(WS-ROW, 7) TO WS-KIND
     MOVE WA-G(WS-ROW, 5) TO WS-VAL(1)
     MOVE WA-G(WS-ROW, 6) TO WS-VAL(2)
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-OBLUNT(2)
     .
 SAMPLE-SCALE-2.
     MOVE WA-I(WS-ROW, 5) TO WS-KIND
     MOVE WA-G(WS-ROW, 1) TO WS-VAL(1)
     MOVE WA-G(WS-ROW, 2) TO WS-VAL(2)
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-OSCALE(2)
     .
*> SIGN-OF-DIFF: WS-SG = the sign of WS-D1 - WS-D2 in IEEE double arithmetic
 SIGN-OF-DIFF.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-D1 WS-D2 WS-D3
     CALL STATIC "cc_f64_signum" USING BY REFERENCE WS-D3 WS-D4
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D4 WS-SG
     .
*> WIND-SUITABLE (7.4 step 6): WS-FLAG 1 when the radius of the object WS-S is at least min_radius_for_wind and its bluntness at least min_bluntness_for_wind (as doubles)
 WIND-SUITABLE.
     MOVE 0 TO WS-FLAG
     IF WS-ORAD(WS-S) >= WA-I(WS-ROW, 9)
         MOVE WS-OBLUNT(WS-S) TO WS-D1
         MOVE WA-F(WS-ROW, 2) TO WS-D5
         CALL "FR-F32" USING WS-D5
         MOVE WS-D5 TO WS-D2
         PERFORM SIGN-OF-DIFF
         IF WS-SG >= 0
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     .
*> HEIGHT-AT: WS-HOUT = (int) getSpeleothemHeight(WS-HD, radius, scale, bluntness) of the object WS-S (7.2, doubles)
 HEIGHT-AT.
     MOVE WS-ORAD(WS-S) TO WS-HRADIUS
     MOVE WS-HD TO WS-D1
     MOVE WS-OBLUNT(WS-S) TO WS-D2
     PERFORM SIGN-OF-DIFF
     IF WS-SG < 0
         MOVE WS-OBLUNT(WS-S) TO WS-HD
     END-IF
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-HD WS-HRADIUS WS-D1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D1 WS-C0384 WS-HT
     CALL STATIC "cc_f64_pow" USING BY REFERENCE WS-HT WS-C43 WS-D1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C075 WS-D1 WS-HA
     CALL STATIC "cc_f64_pow" USING BY REFERENCE WS-HT WS-C23 WS-HB
     CALL STATIC "cc_f64_log" USING BY REFERENCE WS-HT WS-D1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C13 WS-D1 WS-HC
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-HA WS-HB WS-D1
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-D1 WS-HC WS-D2
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-OSCALE(WS-S) WS-D2 WS-HV
*>   the formula is positive for every distance a column cell can have (x = d / r * 0.384 is at most 0.55): no clamp at 0 is needed
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-HV WS-C0384 WS-D1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D1 WS-HRADIUS WS-D2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D2 WS-HOUT
     .
*> OFFSET: (WS-PX, WS-PY, WS-PZ) moved by the wind of 7.4 step 6: the x and z offsets in WS-OFX and WS-OFZ (0 without wind)
 OFFSET.
     MOVE 0 TO WS-OFX WS-OFZ
     IF WS-WIND = 1
         COMPUTE WS-DY = WS-ORIGIN-Y - WS-PY
         MOVE WS-DY TO WS-DYD
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-WIND-X WS-DYD WS-D1
         CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-D1 WS-D2
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D2 WS-OFX
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-WIND-Z WS-DYD WS-D1
         CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-D1 WS-D2
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D2 WS-OFZ
         IF WS-OFX < WS-NEG-OFF
             MOVE WS-NEG-OFF TO WS-OFX
         END-IF
         IF WS-OFX > WS-MAX-OFF
             MOVE WS-MAX-OFF TO WS-OFX
         END-IF
         IF WS-OFZ < WS-NEG-OFF
             MOVE WS-NEG-OFF TO WS-OFZ
         END-IF
         IF WS-OFZ > WS-MAX-OFF
             MOVE WS-MAX-OFF TO WS-OFZ
         END-IF
     END-IF
     .
*> EMBEDDED (7.3): WS-EMB 1 when the circle of the radius WS-NR around (WS-MCX, WS-MCY, WS-MCZ) is mostly embedded in stone
 EMBEDDED.
     MOVE 0 TO WS-EMB
     CALL "FL-GET-STATE" USING WS-MCX WS-MCY WS-MCZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS >= 1 AND WS-CLASS <= 3
         EXIT PARAGRAPH
     END-IF
     MOVE WS-NR TO WS-RADF
     CALL "FX-OP" USING WS-OP-DIV WS-C6 WS-RADF WS-STEP
     MOVE WS-C-ZERO TO WS-ANGLE
     MOVE 1 TO WS-EMB
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-MORE = 0
         MOVE WS-ANGLE TO WS-D1
         MOVE WS-C-TWO-PI TO WS-D2
         PERFORM SIGN-OF-DIFF
         IF WS-SG >= 0
             MOVE 0 TO WS-MORE
         ELSE
             CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE WS-ANGLE WS-COSV
             CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-ANGLE WS-SINV
             CALL "FX-OP" USING WS-OP-MUL WS-COSV WS-RADF WS-D1
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D1 WS-EX
             CALL "FX-OP" USING WS-OP-MUL WS-SINV WS-RADF WS-D1
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D1 WS-EZ
             COMPUTE WS-WX = WS-MCX + WS-EX
             COMPUTE WS-WZ = WS-MCZ + WS-EZ
             CALL "FL-GET-STATE" USING WS-WX WS-MCY WS-WZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS >= 1 AND WS-CLASS <= 3
                 MOVE 0 TO WS-EMB
                 MOVE 0 TO WS-MORE
             ELSE
                 CALL "FX-OP" USING WS-OP-ADD WS-ANGLE WS-STEP WS-D3
                 MOVE WS-D3 TO WS-ANGLE
             END-IF
         END-IF
     END-PERFORM
     .
*> MOVE-BACK (7.5) of the object WS-S: WS-OK 1 when its root now lies where the circle is embedded; the radius shrinks to its half each time no cell of the first (up to) ten works
 MOVE-BACK.
     MOVE 0 TO WS-OK
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-ORAD(WS-S) <= 1 OR WS-DONE = 1
         MOVE WS-ORX(WS-S) TO WS-CX
         MOVE WS-ORY(WS-S) TO WS-CY
         MOVE WS-ORZ(WS-S) TO WS-CZ
         MOVE WS-C-ZERO TO WS-HD
         PERFORM HEIGHT-AT
         MOVE WS-HOUT TO WS-N
         IF WS-N > 10
             MOVE 10 TO WS-N
         END-IF
         MOVE 0 TO WS-I
         PERFORM UNTIL WS-I >= WS-N OR WS-DONE = 1
             CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 3
                 MOVE 1 TO WS-DONE
             ELSE
                 MOVE WS-CX TO WS-PX
                 MOVE WS-CY TO WS-PY
                 MOVE WS-CZ TO WS-PZ
                 PERFORM OFFSET
                 COMPUTE WS-MCX = WS-PX + WS-OFX
                 MOVE WS-PY TO WS-MCY
                 COMPUTE WS-MCZ = WS-PZ + WS-OFZ
                 MOVE WS-ORAD(WS-S) TO WS-NR
                 PERFORM EMBEDDED
                 IF WS-EMB = 1
                     MOVE WS-CX TO WS-ORX(WS-S)
                     MOVE WS-CY TO WS-ORY(WS-S)
                     MOVE WS-CZ TO WS-ORZ(WS-S)
                     MOVE 1 TO WS-OK
                     MOVE 1 TO WS-DONE
                 ELSE
                     IF WS-S = 2
                         SUBTRACT 1 FROM WS-CY
                     ELSE
                         ADD 1 TO WS-CY
                     END-IF
                     ADD 1 TO WS-I
                 END-IF
             END-IF
         END-PERFORM
         IF WS-DONE = 0
             COMPUTE WS-ORAD(WS-S) = WS-ORAD(WS-S) / 2
         END-IF
     END-PERFORM
     .
*> PLACE-BLOCKS (7.6) of the object WS-S
 PLACE-BLOCKS.
     COMPUTE WS-NR = 0 - WS-ORAD(WS-S)
     PERFORM VARYING WS-DX FROM WS-NR BY 1 UNTIL WS-DX > WS-ORAD(WS-S)
         PERFORM VARYING WS-DZ FROM WS-NR BY 1 UNTIL WS-DZ > WS-ORAD(WS-S)
             COMPUTE WS-SQ = WS-DX * WS-DX + WS-DZ * WS-DZ
             MOVE WS-SQ TO WS-SQD
             CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-SQD WS-D1
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D1 WS-DIST
             MOVE WS-ORAD(WS-S) TO WS-D2
             MOVE WS-DIST TO WS-D1
             PERFORM SIGN-OF-DIFF
             IF WS-SG <= 0
                 MOVE WS-DIST TO WS-HD
                 PERFORM HEIGHT-AT
                 MOVE WS-HOUT TO WS-H
                 IF WS-H > 0
                     PERFORM PLACE-COLUMN
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 PLACE-COLUMN.
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F3
     MOVE WS-F3 TO WS-D1
     MOVE WS-C-02 TO WS-D2
     PERFORM SIGN-OF-DIFF
     IF WS-SG < 0
*>       h = (int)((float) h * Mth.randomBetween(random, 0.8f, 1.0f)), randomBetween = nextFloat() * (1.0f - 0.8f) + 0.8f
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F4
         CALL "FX-OP" USING WS-OP-SUB WS-C-10 WS-C-08 WS-D3
         CALL "FX-OP" USING WS-OP-MUL WS-F4 WS-D3 WS-D4
         CALL "FX-OP" USING WS-OP-ADD WS-D4 WS-C-08 WS-D5
         MOVE WS-H TO WS-FH
         CALL "FX-OP" USING WS-OP-MUL WS-FH WS-D5 WS-D4
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D4 WS-H
     END-IF
     COMPUTE WS-CX = WS-ORX(WS-S) + WS-DX
     MOVE WS-ORY(WS-S) TO WS-CY
     COMPUTE WS-CZ = WS-ORZ(WS-S) + WS-DZ
     MOVE 0 TO WS-PLACED
     IF WS-S = 2
         CALL "FL-HEIGHT-OF" USING WS-ORD0 WS-CX WS-CZ WS-LIMIT
     ELSE
         MOVE 2147483647 TO WS-LIMIT
     END-IF
     MOVE 0 TO WS-I
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-I >= WS-H OR WS-CY >= WS-LIMIT OR WS-DONE = 1
         MOVE WS-CX TO WS-PX
         MOVE WS-CY TO WS-PY
         MOVE WS-CZ TO WS-PZ
         PERFORM OFFSET
         COMPUTE WS-WX = WS-PX + WS-OFX
         COMPUTE WS-WZ = WS-PZ + WS-OFZ
         MOVE WS-PY TO WS-WY
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS >= 1 AND WS-CLASS <= 3
             MOVE 1 TO WS-PLACED
             MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 1)) TO WS-DRIP-STATE
             CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-DRIP-STATE WS-FLAGS WS-WRITTEN
         ELSE
             IF WS-PLACED = 1
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 2) WA-N(WS-ROW, 2) WS-BLOCK WS-FLAG
                 IF WS-FLAG = 1
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-IF
         IF WS-DONE = 0
             IF WS-S = 2
                 ADD 1 TO WS-CY
             ELSE
                 SUBTRACT 1 FROM WS-CY
             END-IF
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-DRIP.
