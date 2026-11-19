*> Equivalence and cost test of the mesher (lane perfframe): 3 x 3 chunk rows whose first four sections are filled by a hash with air, greystone, lucite and water
*> (the stand-in states and the fluid states of test_mesher_fluid), light by another hash, are meshed section by section (MESH-SECTION: faces against neighbours inside
*> the row and across rows, fluid mesh, light of the cell a face looks into), and the opaque and translucent vertices of every section are digested (CRC-32 of the 44-byte
*> records, summed with the section's place as weight). The digest was taken from the code before the lane's changes and must stay the same byte for byte; the CPU
*> time of the meshing is shown (PERF) and bounded. Lane bugfluidwalls changed the fluid quads on purpose (the front copy of a face has its corners reversed for the culling
*> pipeline, the sides are made again for the inside, the top again only where shouldRenderBackwardUpFace holds; 29a 10.3), so the digest was taken again: 8248849812848199119 before.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-DIGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROWS.
    05 WS-ROW              BINARY-LONG OCCURS 9 TIMES.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 01 WS-BYTES               BINARY-DOUBLE.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED.
 01 WS-DIGEST              BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-WEIGHT              BINARY-DOUBLE.
 01 WS-VERTS               BINARY-DOUBLE VALUE 0.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE VALUE 0.
 01 WS-D19                 PIC Z(18)9.
 01 WS-D9                  PIC Z(8)9.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-WATER               BINARY-DOUBLE.
 01 WS-GRASS               BINARY-DOUBLE.
 01 WS-FOLIAGE             BINARY-DOUBLE.
 01 WS-DRY                 BINARY-DOUBLE VALUE -1.
 01 WS-MOD                 PIC X(16) VALUE "none".
 01 WS-BIOME               BINARY-LONG.
 01 WS-SPRITE-N            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         ADD 1 TO AT-SPRITE-COUNT
         MOVE AT-SPRITE-COUNT TO WS-SPRITE-N
         MOVE SPACES TO AT-NAME(WS-SPRITE-N)
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:block/water_still" TO AT-NAME(WS-SPRITE-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-SPRITE-N)
             WHEN 2
                 MOVE "minecraft:block/water_flow" TO AT-NAME(WS-SPRITE-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-SPRITE-N)
             WHEN 3
                 MOVE "minecraft:block/water_overlay" TO AT-NAME(WS-SPRITE-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-SPRITE-N)
             WHEN 4
                 MOVE "minecraft:block/lava_still" TO AT-NAME(WS-SPRITE-N)
                 MOVE 0 TO AT-TRANSLUCENT(WS-SPRITE-N)
             WHEN OTHER
                 MOVE "minecraft:block/lava_flow" TO AT-NAME(WS-SPRITE-N)
                 MOVE 0 TO AT-TRANSLUCENT(WS-SPRITE-N)
         END-EVALUATE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(AT-NAME(WS-SPRITE-N))) TO AT-NAME-LENGTH(WS-SPRITE-N)
         COMPUTE AT-X(WS-SPRITE-N) = 2 * WS-I
         MOVE 0 TO AT-Y(WS-SPRITE-N)
         MOVE 16 TO AT-SW(WS-SPRITE-N) AT-SH(WS-SPRITE-N)
     END-PERFORM
     MOVE 1 TO ST-FLUID(311) ST-FLUID(312)
     MOVE 3 TO ST-FLUID(314)
     MOVE 2 TO ST-FLUID(313)
     MOVE 0 TO ST-LEVEL(311) ST-LEVEL(313)
     MOVE 3 TO ST-LEVEL(312) ST-LEVEL(314)
     MOVE 0 TO ST-OPAQUE(311) ST-OPAQUE(312) ST-OPAQUE(313) ST-OPAQUE(314)
     MOVE 0.6 TO WS-T
     MOVE 0.4 TO WS-D
     MOVE 4282349284 TO WS-WATER
     MOVE 4283404090 TO WS-GRASS
     MOVE 4284119852 TO WS-FOLIAGE
     MOVE 0 TO WS-BIOME
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-D WS-WATER WS-GRASS WS-FOLIAGE WS-DRY WS-MOD
*>   The replica: rows of the chunks (-1 to 1, -1 to 1), the cells of the first four sections by hash, the light by another.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-CX FROM -1 BY 1 UNTIL WS-CX > 1
         PERFORM VARYING WS-CZ FROM -1 BY 1 UNTIL WS-CZ > 1
             ADD 1 TO WS-N
             CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW(WS-N)
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-N))
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16384
                 COMPUTE WS-H = FUNCTION MOD(WS-K * 7919 + WS-N * 104729 + (WS-K / 256) * 31, 40)
                 EVALUATE TRUE
                     WHEN WS-H >= 4 AND WS-H < 25
                         MOVE 2 TO CE-STATE(WS-K)
                     WHEN WS-H = 25 OR WS-H = 26
                         MOVE 12 TO CE-STATE(WS-K)
                     WHEN WS-H = 27
                         MOVE 310 TO CE-STATE(WS-K)
                     WHEN OTHER
                         MOVE 0 TO CE-STATE(WS-K)
                 END-EVALUATE
             END-PERFORM
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 53248
                 COMPUTE CE-SKY(WS-K) = FUNCTION MOD(WS-K * 31 + WS-N * 7, 256)
                 COMPUTE CE-BLOCK-LIGHT(WS-K) = FUNCTION MOD(WS-K * 17 + WS-N * 13, 251)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
             MOVE WS-ROW(WS-I) TO WS-R
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5
                 CALL STATIC "clock" RETURNING WS-T0
                 CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                 CALL STATIC "clock" RETURNING WS-T1
                 IF WS-PASS = 2
                     COMPUTE WS-US = WS-US + WS-T1 - WS-T0
                     COMPUTE WS-WEIGHT = (WS-I * 10 + WS-S) * 1000003
                     ADD WR-OP-COUNT(WS-R, WS-S) TO WS-VERTS
                     ADD WR-TR-COUNT(WS-R, WS-S) TO WS-VERTS
                     IF WR-OP-COUNT(WS-R, WS-S) > 0
                         COMPUTE WS-BYTES = WR-OP-COUNT(WS-R, WS-S) * 44
                         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY VALUE WR-OP-ADDR(WS-R, WS-S) BY VALUE WS-BYTES RETURNING WS-CRC
                         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
                     END-IF
                     IF WR-TR-COUNT(WS-R, WS-S) > 0
                         COMPUTE WS-BYTES = WR-TR-COUNT(WS-R, WS-S) * 44
                         CALL STATIC "crc32" USING BY VALUE WS-ZERO BY VALUE WR-TR-ADDR(WS-R, WS-S) BY VALUE WS-BYTES RETURNING WS-CRC
                         COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT * 3, 9223372036854775783)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-US TO WS-D19
     DISPLAY "PERF mesher us for 45 sections: " WS-D19
     MOVE WS-VERTS TO WS-D19
     DISPLAY "vertices " WS-D19
     MOVE WS-DIGEST TO WS-D19
     DISPLAY "DIGEST mesher " WS-D19
     MOVE "T" TO TL-MODE
     MOVE "test mesher digest: the meshes of 45 sections have the digest taken before the optimisations" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "7516184377384486697" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-D19) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mesher digest: the sections have vertices (the digest is not of nothing)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VERTS > 100000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MESHER-DIGEST.
 COPY CLTEST.
