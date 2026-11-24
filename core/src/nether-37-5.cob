*> The Nether's decoration (docs/protocol/37-nether-5; T1689 to T1700): the global feature order of the five biomes with the seed offsets (section 3, NETHERFT.cpy) and the
*> decoration driver of one chunk, which runs the placed features of the biomes present in the chunk through the placement runtime of the feature stage (feat-run.cob,
*> feat-level.cob: FR-PLACE-PF through the level of the chunk) in (step, index) order, each seeded with decorationSeed + index + 10000 * step (35-1 section 5.1; 3).
*> The level is the Nether's generation range: min y 0, height 128, sea level 32 (section 1.3; blocks above y 127 are not written).
*> Deviations (the runtime's, listed in feat-stage.cob): only the biomes of this chunk's own cells select the features (not the 3 x 3 neighbourhood), only blocks of this
*> chunk are written, and a placed feature whose configured feature type the runtime does not compile places nothing (the ore, spring, glowstone, delta and fungus
*> leaf types are open items). A placed feature the data folder or content set does not hold is skipped.
*>
*> Entry points:
*>   NETHER-FEATURE-ROW USING row (1 to 37), step (0 to 10), index (within the step), offset (index + 10000 * step), key out (PIC X(26), no namespace), biomes out (PIC X(5): W S C P D or .)
*>   NETHER-GEN-FEATURES USING world seed (BINARY-DOUBLE, signed: the level seed), chunk x, chunk z (BINARY-LONG), chunk memory (the CELLS.cpy block of NETHER-GEN-CHUNK),
*>     features selected out (BINARY-LONG: the placed features of the order the chunk's biomes list, whether or not their data places anything)
*>   It needs the block table of the open world (CBLOCKS.cpy), the biome cells written by NETHER-GEN-CHUNK (NETHER-STATES has filled NH-BIOME-ID) and the placed feature data.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FEATURE-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERFT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-KEY                  PIC X(26).
 01 L-BIOMES               PIC X(5).
 PROCEDURE DIVISION USING L-ROW L-STEP L-INDEX L-OFFSET L-KEY L-BIOMES.
     MOVE NF-STEP(L-ROW) TO L-STEP
     MOVE NF-INDEX(L-ROW) TO L-INDEX
     COMPUTE L-OFFSET = L-INDEX + 10000 * L-STEP
     MOVE NF-KEY(L-ROW) TO L-KEY
     MOVE NF-MASK(L-ROW) TO L-BIOMES
     GOBACK.
 END PROGRAM NETHER-FEATURE-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GEN-FEATURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CBLOCKS.
 COPY NETHER.
 COPY NETHERFT.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-STAMP-CB            BINARY-LONG VALUE -1.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PRESENT             PIC X(5).
 01 WS-MASK                PIC X(5).
 01 WS-N                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-INDEX0              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 128.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-CHUNK L-PLACED.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     SET WS-PTR TO ADDRESS OF L-CHUNK
     MOVE 0 TO L-PLACED
     IF WS-STAMP-CB NOT = CB-EPOCH
         CALL "FD-RESET"
         MOVE CB-EPOCH TO WS-STAMP-CB
     END-IF
*>   the biomes present in the chunk's cells
     MOVE "....." TO WS-PRESENT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 1536 OR WS-PRESENT(WS-N:1) NOT = "."
             IF CE-BIOME(WS-CELL) = NH-BIOME-ID(WS-N)
                 MOVE "x" TO WS-PRESENT(WS-N:1)
             END-IF
         END-PERFORM
     END-PERFORM
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     COMPUTE WS-BX = L-CX * 16
     COMPUTE WS-BZ = L-CZ * 16
     CALL "FL-OPEN" USING WS-PTR L-CX L-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "ORE-DECOR-SEED" USING WS-U WS-BX WS-BZ WS-XR WS-DECOR
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 37
         MOVE NF-MASK(WS-R) TO WS-MASK
         MOVE 0 TO WS-RUN
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
             IF WS-MASK(WS-N:1) NOT = "." AND WS-PRESENT(WS-N:1) NOT = "."
                 MOVE 1 TO WS-RUN
             END-IF
         END-PERFORM
         IF WS-RUN = 1
             MOVE NF-STEP(WS-R) TO WS-STEP
             MOVE NF-INDEX(WS-R) TO WS-INDEX0
             CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX0 WS-STEP WS-FSEED
             CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
             MOVE SPACES TO WS-KEY
             STRING "minecraft:" FUNCTION TRIM(NF-KEY(WS-R)) DELIMITED BY SIZE INTO WS-KEY
             CALL "FD-GET-PF" USING WS-KEY WS-PF
             ADD 1 TO L-PLACED
             IF WS-PF > 0
                 MOVE WS-PF TO WS-TOP
                 CALL "FR-PLACE-PF" USING WS-XR WS-PF WS-TOP WS-BX WS-MIN-Y WS-BZ WS-RESULT
             END-IF
         END-IF
     END-PERFORM
     CALL "FL-CLOSE"
     GOBACK.
 END PROGRAM NETHER-GEN-FEATURES.
