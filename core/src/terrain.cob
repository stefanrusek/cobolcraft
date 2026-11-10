*> The terrain fill (docs/protocol/10 section 8.1; T0419): the stone, fluid and air of a chunk from the final density and the
*> aquifer, one slab of four block rows per call (the step of the generation job, gen-job.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TERRAIN-FILL-SLAB.
*> USING job: slab GJ-SUB (0 to 95: block rows y = -64 + 4 * GJ-SUB to +3) of the terrain fill of 10 section 8.1: each block is stone
*> where the final density is above 0, else what the aquifer says (AQUIFER-SUBSTANCE: fluid or air). The interpolated nodes
*> read the chunk's grids. Both heightmaps rise with the blocks placed (the slabs go bottom up, so the highest block wins
*> as the downward scan of the document finds it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY DENSITY.
 COPY GENSTAGE.
 01 WS-KEY-STONE           PIC X(48) VALUE "minecraft:stone".
 01 WS-KEY-WATER           PIC X(48) VALUE "minecraft:water".
 01 WS-KEY-LAVA            PIC X(48) VALUE "minecraft:lava".
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 01 WS-GT                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-DENSITY
     CALL "GEN-BLOCK-STATE" USING WS-KEY-STONE WS-STONE
     CALL "GEN-BLOCK-STATE" USING WS-KEY-WATER WS-WATER
     CALL "GEN-BLOCK-STATE" USING WS-KEY-LAVA WS-LAVA
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     MOVE 1 TO DNG-ACTIVE
     COMPUTE DNG-X0 = J-CX * 16
     COMPUTE DNG-Z0 = J-CZ * 16
     SET DNG-PTR TO ADDRESS OF J-GRID
     PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
         PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
             COMPUTE WS-X = J-CX * 16 + WS-LX
             COMPUTE WS-Z = J-CZ * 16 + WS-LZ
             COMPUTE WS-COL = WS-LZ * 16 + WS-LX + 1
             PERFORM VARYING WS-LY FROM 3 BY -1 UNTIL WS-LY < 0
                 COMPUTE WS-Y = -64 + J-SUB * 4 + WS-LY
                 CALL "DENSITY-NODE" USING J-FINAL-ROOT WS-X WS-Y WS-Z WS-D
                 CALL "FCMP-GT" USING WS-D WS-ZERO-F WS-GT
                 IF WS-GT = 1
                     MOVE 0 TO WS-KIND
                 ELSE
                     CALL "AQUIFER-SUBSTANCE" USING L-JOB WS-X WS-Y WS-Z WS-D WS-KIND
                 END-IF
                 EVALUATE WS-KIND
                     WHEN 1
                         MOVE 0 TO WS-STATE
                     WHEN 2
                         MOVE WS-WATER TO WS-STATE
                     WHEN 3
                         MOVE WS-LAVA TO WS-STATE
                     WHEN OTHER
                         MOVE WS-STONE TO WS-STATE
                 END-EVALUATE
                 IF WS-KIND NOT = 1
                     COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
                     MOVE WS-STATE TO CE-STATE(WS-CELL)
                     IF WS-Y > J-HM-SURFACE(WS-COL)
                         MOVE WS-Y TO J-HM-SURFACE(WS-COL)
                     END-IF
                     IF (WS-KIND = 0 OR WS-KIND = 4) AND WS-Y > J-HM-OCEAN(WS-COL)
                         MOVE WS-Y TO J-HM-OCEAN(WS-COL)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO DNG-ACTIVE
     GOBACK.
 END PROGRAM TERRAIN-FILL-SLAB.

