*> The End's decoration driver (docs/protocol/38-end.md section 8 table; T1735, T1736, T1743, T1744): the placed features of the five End biomes in the global order of
*> 11 section 4 (step, index): step 0 end_island_decorated (small_end_islands), step 4 end_spike (the_end) and end_gateway_return (end_highlands), step 9 chorus_plant
*> (end_highlands), step 10 end_platform (the_end). Each is seeded decorationSeed + index + 10000 * step (35-1 section 5.1) and run through its modifiers in the
*> evaluation order of 35-1 section 8.2 (the draws: rarity_filter one float, count the provider's, in_square x then z, height_range, offset), written into the
*> level of the chunk (FL-OPEN) by the leaf programs of end-38c.cob. The placement runtime of feat-run.cob has no leaf types for these features, so the modifiers
*> are coded here instead of read from the placed feature data (the numbers are the table of 38 section 8). Deviations, as the Nether driver: the biome of a
*> chunk is its own (the source answers per chunk), only blocks of this chunk are written.
*>
*> Entry point:
*>   END-GEN-FEATURES USING world seed (BINARY-DOUBLE, signed), chunk x, chunk z, chunk memory (CELLS.cpy, made by END-GEN-CHUNK), crystal list out (ENDSPIKE.cpy: the
*>     end crystals the chunk's pillars ask for), placed out (BINARY-LONG: the placed features run for the chunk's biome).
*>   It needs the block table of the open world (CBLOCKS.cpy) and END-STATES done.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-ROLL.
*> USING random (XORO.cpy), chunk block x, block z: the modifiers of end_gateway_return after the rarity filter: in_square, MOTION_BLOCKING height (dropped when it is
*> not above min y), offset y 3 to 9, then the gateway (the level of the chunk must be open, FL-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N16                 BINARY-LONG VALUE 16.
 01 WS-N7                  BINARY-LONG VALUE 7.
 01 WS-HMAP                BINARY-LONG VALUE 4.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-MINY                BINARY-LONG VALUE 0.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BX                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BX L-BZ.
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N16 WS-D
     COMPUTE WS-X = L-BX + WS-D
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N16 WS-D
     COMPUTE WS-Z = L-BZ + WS-D
     CALL "FL-HEIGHT-OF" USING WS-HMAP WS-X WS-Z WS-H
     IF WS-H > WS-MINY
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N7 WS-D
         COMPUTE WS-Y = WS-H + 3 + WS-D
         CALL "END-GATEWAY-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z
     END-IF
     GOBACK.
 END PROGRAM END-GATEWAY-ROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-FEATURE.
*> USING random (XORO.cpy), chunk block x, block z: end_gateway_return: the rarity filter 700 (one float draw, passes below 1 / 700 in float), then END-GATEWAY-ROLL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-K700                FLOAT-LONG VALUE 700.
 01 WS-F                   FLOAT-LONG.
 01 WS-THR                 FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BX                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BX L-BZ.
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     CALL "DENSITY-F32" USING WS-OP-DIV WS-ONE WS-K700 WS-THR
     CALL "FCMP-GT" USING WS-THR WS-F WS-GT
     IF WS-GT = 1
         CALL "END-GATEWAY-ROLL" USING L-STATE L-BX L-BZ
     END-IF
     GOBACK.
 END PROGRAM END-GATEWAY-FEATURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GEN-FEATURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-K14                 FLOAT-LONG VALUE 14.
 01 WS-K700                FLOAT-LONG VALUE 700.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PTR                 USAGE POINTER.
 01 WS-MINY                BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-BIOME               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-N16                 BINARY-LONG VALUE 16.
 01 WS-N4                  BINARY-LONG VALUE 4.
 01 WS-N5                  BINARY-LONG VALUE 5.
 01 WS-N7                  BINARY-LONG VALUE 7.
 01 WS-F                   FLOAT-LONG.
 01 WS-THR                 FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-DROP                BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-HMAP                BINARY-LONG VALUE 4.
 01 WS-PX                  BINARY-LONG VALUE 100.
 01 WS-PY                  BINARY-LONG VALUE 49.
 01 WS-PZ                  BINARY-LONG VALUE 0.
 01 WS-ROWS.
    05 FILLER              PIC X(4) VALUE "0004".
    05 FILLER              PIC X(4) VALUE "0401".
    05 FILLER              PIC X(4) VALUE "0412".
    05 FILLER              PIC X(4) VALUE "0902".
    05 FILLER              PIC X(4) VALUE "1001".
 01 WS-ROW-TAB REDEFINES WS-ROWS.
    05 WS-R                OCCURS 5 TIMES.
       10 WS-R-STEP        PIC 99.
       10 WS-R-INDEX       PIC 9.
       10 WS-R-BIOME       PIC 9.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-CRYSTALS.
    05 L-EC-COUNT          BINARY-LONG.
    05 L-EC-ROW            OCCURS 10 TIMES.
       10 L-EC-X           BINARY-LONG.
       10 L-EC-Y           BINARY-LONG.
       10 L-EC-Z           BINARY-LONG.
       10 L-EC-YAW         FLOAT-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-CHUNK L-CRYSTALS L-PLACED.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     SET WS-PTR TO ADDRESS OF L-CHUNK
     MOVE 0 TO L-PLACED L-EC-COUNT
     CALL "END-BIOME-OF" USING L-CX L-CZ WS-BIOME
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     COMPUTE WS-BX = L-CX * 16
     COMPUTE WS-BZ = L-CZ * 16
     CALL "FL-OPEN" USING WS-PTR L-CX L-CZ WS-MINY WS-HEIGHT WS-SEA
     CALL "ORE-DECOR-SEED" USING WS-U WS-BX WS-BZ WS-XR WS-DECOR
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 5
         IF WS-R-BIOME(WS-ROW) = WS-BIOME
             MOVE WS-R-STEP(WS-ROW) TO WS-STEP
             MOVE WS-R-INDEX(WS-ROW) TO WS-INDEX
             CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FSEED
             CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
             ADD 1 TO L-PLACED
             EVALUATE WS-ROW
                 WHEN 1
*>                   end_island_decorated: rarity 14, count 1 (weight 3) or 2 (weight 1), in_square, height 55 to 70
                     CALL "WGR-NEXT-FLOAT" USING WS-XR WS-F
                     CALL "DENSITY-F32" USING WS-OP-DIV WS-ONE WS-K14 WS-THR
                     CALL "FCMP-GT" USING WS-THR WS-F WS-GT
                     IF WS-GT = 1
                         CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N4 WS-D
                         MOVE 1 TO WS-COUNT
                         IF WS-D >= 3
                             MOVE 2 TO WS-COUNT
                         END-IF
                         PERFORM WS-COUNT TIMES
                             CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N16 WS-D
                             COMPUTE WS-X = WS-BX + WS-D
                             CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N16 WS-D
                             COMPUTE WS-Z = WS-BZ + WS-D
                             CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N16 WS-D
                             COMPUTE WS-Y = 55 + WS-D
                             CALL "END-ISLAND-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-XR
                         END-PERFORM
                     END-IF
                 WHEN 2
*>                   end_spike: the biome filter only, the origin is the chunk's minimum corner
                     CALL "END-SPIKE-PLACE" USING WS-MODE WS-DIM WS-BX WS-BZ L-SEED WS-XR L-CRYSTALS
                 WHEN 3
*>                   end_gateway_return: rarity 700, in_square, MOTION_BLOCKING height, offset y 3 to 9
                     CALL "END-GATEWAY-FEATURE" USING WS-XR WS-BX WS-BZ
                 WHEN 4
*>                   chorus_plant: count 0 to 4, in_square, MOTION_BLOCKING height
                     CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N5 WS-COUNT
                     PERFORM WS-COUNT TIMES
                         CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N16 WS-D
                         COMPUTE WS-X = WS-BX + WS-D
                         CALL "WGR-NEXT-INT-BOUND" USING WS-XR WS-N16 WS-D
                         COMPUTE WS-Z = WS-BZ + WS-D
                         CALL "FL-HEIGHT-OF" USING WS-HMAP WS-X WS-Z WS-H
                         IF WS-H > WS-MINY
                             CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM WS-X WS-H WS-Z WS-XR WS-RESULT
                         END-IF
                     END-PERFORM
                 WHEN OTHER
*>                   end_platform: fixed_placement [[100, 49, 0]], only while its own chunk is decorated
                     IF L-CX = 6 AND L-CZ = 0
                         CALL "END-PLATFORM-PLACE" USING WS-MODE WS-DIM WS-PX WS-PY WS-PZ WS-DROP WS-DROPPED
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "FL-CLOSE"
     GOBACK.
 END PROGRAM END-GEN-FEATURES.
