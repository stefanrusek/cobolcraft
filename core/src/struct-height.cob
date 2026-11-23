*> The column query of the structure generators: the height of a world column of the overworld from the noise-based terrain alone, the getBaseHeight of
*> docs/protocol/37-nether-2 section 6.5 (a one-column volume of final_density, walked from the top block down, no surface rule, carver or structure) applied to the
*> overworld's final density, which the same interpolation of 6.2 and the chunk grids of the generator (GENGRID.cpy) compute. A structure whose start sits in a chunk
*> other than the one being generated reads the heights of columns the generator has not made yet, so the query does not read blocks.
*>
*> Method (exact against the terrain fill, not an approximation): the interpolated nodes of the final density take their eight corner values from the grid of cell corners
*> (4 by 8 by 4 blocks, y from -64), so a column needs the corners of the 2 x 2 columns of corners around it, at the 49 heights; each corner column is computed on demand,
*> level by level from the top, and remembered (a cache of 512 corner columns, keyed by the corner's x and z, cleared when the content or the noise generation changes).
*> The query then walks the 47 cell rows from the top down exactly like the fill: DENSITY-HULL bounds the final density over the cell (a margin of 0.001, as in the fill),
*> a cell whose upper bound is below 0 holds no stone, any other cell is evaluated block by block from its top with DENSITY-NODE in grid mode until
*> the density is above 0 (a cell that is stone throughout ends at its first block). The first stone from the top is the top of the solid column.
*>
*> Heights are the y above the first block that satisfies the heightmap predicate (the FL-HEIGHT-OF convention), kind 0 WORLD_SURFACE_WG (stone or fluid), kind 1 OCEAN_FLOOR_WG
*> (stone only): the fluid is the global fluid picker's (AQ-PICKER: water below 63, lava below -54, the disabled aquifer of the column query), so WORLD_SURFACE_WG is the larger of
*> the stone top and the sea level, and a column with no stone is the sea level (kind 0) or the bottom of the world, -64 (kind 1: "minY when nothing matches").
*>
*> Entry point: STRUCT-BASE-HEIGHT USING x, z, kind (0 or 1), height out (BINARY-LONG).
*> The query is a pure function of the world seed, the content and the column, so the cache never changes a result, only the cost.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BASE-HEIGHT.
*> USING x, z, kind, height out: the column query without structures (37-2 section 6.5, 36-1 5.4): the beardifier of the chunk being generated (STRUCTBEARD.cpy) is switched off for the walk and
*> back on after it, with SBD-GEN changed each way so that the density memo does not carry a value over (STRUCT-BASE-HEIGHT-RAW is the walk).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 01 WS-WAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-KIND L-HEIGHT.
     MOVE SBD-ACTIVE TO WS-WAS
     IF WS-WAS = 1
         MOVE 0 TO SBD-ACTIVE
         ADD 1 TO SBD-GEN
     END-IF
     CALL "STRUCT-BASE-HEIGHT-RAW" USING L-X L-Z L-KIND L-HEIGHT
     IF WS-WAS = 1
         MOVE 1 TO SBD-ACTIVE
         ADD 1 TO SBD-GEN
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BASE-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BASE-HEIGHT-RAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY NOISE.
 COPY DENSITY.
 78 SH-CACHE-SIZE          VALUE 512.
 01 WS-KIND-FN             BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld/final_density".
 01 WS-STAMP               BINARY-LONG VALUE -1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NODES.
    05 WS-NODE             BINARY-LONG OCCURS 16 TIMES.
 01 WS-CACHE.
    05 WS-ENTRY OCCURS 512 TIMES.
       10 WS-E-USED        BINARY-LONG VALUE 0.
       10 WS-E-X           BINARY-LONG.
       10 WS-E-Z           BINARY-LONG.
       10 WS-E-HAVE        PIC 9 OCCURS 49 TIMES.
       10 WS-E-VAL         FLOAT-LONG OCCURS 784 TIMES.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==SG-==.
 01 WS-LOADED.
    05 WS-LOAD             PIC 9 OCCURS 49 TIMES.
 01 WS-SAVE-ACTIVE         BINARY-LONG.
 01 WS-SAVE-X0             BINARY-LONG.
 01 WS-SAVE-Z0             BINARY-LONG.
 01 WS-SAVE-PTR            USAGE POINTER.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-CI                  BINARY-LONG.
 01 WS-CK                  BINARY-LONG.
 01 WS-CJ                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LVL                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DC                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-COLS.
    05 WS-COL OCCURS 4 TIMES.
       10 WS-COL-E         BINARY-LONG.
       10 WS-COL-X         BINARY-LONG.
       10 WS-COL-Z         BINARY-LONG.
       10 WS-COL-G         BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SOLID-TOP           BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 01 WS-MINUS-SURE          FLOAT-LONG VALUE -0.001.
 01 WS-GT                  BINARY-LONG.
 01 WS-SEA-Y               BINARY-LONG VALUE 62.
 01 WS-SEA                 BINARY-LONG.
 01 WS-SEA-TYPE            BINARY-LONG.
*> the heights of whole columns (both kinds, one walk), keyed by the column's place in a 128 x 128 column tile; an entry holds the stamp it was made under
 01 WS-COLUMNS.
    05 WS-COLUMN OCCURS 16384 TIMES.
       10 WS-K-STAMP       BINARY-LONG VALUE -1.
       10 WS-K-X           BINARY-LONG.
       10 WS-K-Z           BINARY-LONG.
       10 WS-K-H0          BINARY-LONG.
       10 WS-K-H1          BINARY-LONG.
 01 WS-KX                  BINARY-LONG.
 01 WS-KZ                  BINARY-LONG.
 01 WS-KSLOT               BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-FLAT-WORLD          BINARY-LONG.
 01 WS-FLAT-ORDINAL        BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-KIND L-HEIGHT.
*>   A superflat world has no noise terrain: the column's height is the flat generator's getBaseHeight (56 section 4.6), the same in every column.
     CALL "WORLD-IS-FLAT" USING WS-FLAT-WORLD
     IF WS-FLAT-WORLD = 1
         MOVE 0 TO WS-FLAT-ORDINAL
         IF L-KIND = 1
             MOVE 2 TO WS-FLAT-ORDINAL
         END-IF
         CALL "FLAT-BASE-HEIGHT" USING WS-FLAT-ORDINAL L-HEIGHT
         GOBACK
     END-IF
*>   the interpolated nodes of the final density, found again when the content or the noises change (their stamp)
     COMPUTE WS-LVL = WG-LOAD-GEN + NZ-GEN
*>   a column asked before under this stamp is answered from the column cache (the query is a pure function of the stamp and the column)
     COMPUTE WS-KX = FUNCTION MOD(L-X, 128)
     COMPUTE WS-KZ = FUNCTION MOD(L-Z, 128)
     COMPUTE WS-KSLOT = WS-KX * 128 + WS-KZ + 1
     IF WS-K-STAMP(WS-KSLOT) = WS-LVL AND WS-K-X(WS-KSLOT) = L-X AND WS-K-Z(WS-KSLOT) = L-Z
         IF L-KIND = 1
             MOVE WS-K-H1(WS-KSLOT) TO L-HEIGHT
         ELSE
             MOVE WS-K-H0(WS-KSLOT) TO L-HEIGHT
         END-IF
         GOBACK
     END-IF
     IF WS-LVL NOT = WS-STAMP
         MOVE WS-LVL TO WS-STAMP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SH-CACHE-SIZE
             MOVE 0 TO WS-E-USED(WS-I)
         END-PERFORM
         CALL "WG-FIND" USING WS-KIND-FN WS-KEY WS-ROOT
         MOVE 0 TO SG-G-COUNT
         CALL "GEN-FIND-INTERP" USING WS-ROOT WS-JOB
         MOVE SG-G-COUNT TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE SG-G-NODE(WS-I) TO WS-NODE(WS-I)
         END-PERFORM
     END-IF
     MOVE WS-COUNT TO SG-G-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NODE(WS-I) TO SG-G-NODE(WS-I)
     END-PERFORM
*>   the chunk column the query column lies in, its cell, and the four corner columns of the cell (the chunk grid's corner (i, k) is at (x0 + 4 i, z0 + 4 k))
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X / 16) * 16
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z / 16) * 16
     COMPUTE WS-CI = (L-X - WS-X0) / 4
     COMPUTE WS-CK = (L-Z - WS-Z0) / 4
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
         COMPUTE WS-DC = WS-C - 1
         DIVIDE WS-DC BY 2 GIVING WS-DZ REMAINDER WS-DX
         COMPUTE WS-COL-X(WS-C) = WS-X0 + 4 * (WS-CI + WS-DX)
         COMPUTE WS-COL-Z(WS-C) = WS-Z0 + 4 * (WS-CK + WS-DZ)
         COMPUTE WS-COL-G(WS-C) = (WS-CI + WS-DX) * 5 + WS-CK + WS-DZ
         COMPUTE WS-CX = WS-COL-X(WS-C) / 4
         COMPUTE WS-CZ = WS-COL-Z(WS-C) / 4
         COMPUTE WS-HASH = FUNCTION MOD(WS-CX * 7919 + WS-CZ * 104729, SH-CACHE-SIZE) + 1
         IF WS-E-USED(WS-HASH) = 0 OR WS-E-X(WS-HASH) NOT = WS-COL-X(WS-C) OR WS-E-Z(WS-HASH) NOT = WS-COL-Z(WS-C)
             MOVE 1 TO WS-E-USED(WS-HASH)
             MOVE WS-COL-X(WS-C) TO WS-E-X(WS-HASH)
             MOVE WS-COL-Z(WS-C) TO WS-E-Z(WS-HASH)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 49
                 MOVE 0 TO WS-E-HAVE(WS-HASH, WS-I)
             END-PERFORM
         END-IF
         MOVE WS-HASH TO WS-COL-E(WS-C)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 49
         MOVE 0 TO WS-LOAD(WS-I)
     END-PERFORM
*>   the grid mode of the density evaluator points at the scratch grid for the walk
     MOVE DNG-ACTIVE TO WS-SAVE-ACTIVE
     MOVE DNG-X0 TO WS-SAVE-X0
     MOVE DNG-Z0 TO WS-SAVE-Z0
     SET WS-SAVE-PTR TO DNG-PTR
     MOVE 0 TO DNG-ACTIVE
     MOVE -1 TO WS-SOLID-TOP
     MOVE 0 TO WS-FOUND
     MOVE 47 TO WS-CJ
     PERFORM UNTIL WS-CJ < 0 OR WS-FOUND = 1
*>       the corner levels WS-CJ and WS-CJ + 1 of the four corner columns: cached values into the scratch grid
         PERFORM VARYING WS-LEVEL FROM WS-CJ BY 1 UNTIL WS-LEVEL > WS-CJ + 1
             COMPUTE WS-LVL = WS-LEVEL + 1
             IF WS-LOAD(WS-LVL) = 0
                 MOVE 1 TO WS-LOAD(WS-LVL)
                 PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                     MOVE WS-COL-E(WS-C) TO WS-HASH
                     IF WS-E-HAVE(WS-HASH, WS-LVL) = 0
                         MOVE 1 TO WS-E-HAVE(WS-HASH, WS-LVL)
                         COMPUTE WS-Y = -64 + 8 * WS-LEVEL
                         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT
                             CALL "DENSITY-NODE" USING WGN-CHILD(WS-NODE(WS-N), 1) WS-COL-X(WS-C) WS-Y WS-COL-Z(WS-C) WS-D
                             COMPUTE WS-SLOT = (WS-N - 1) * 49 + WS-LVL
                             MOVE WS-D TO WS-E-VAL(WS-HASH, WS-SLOT)
                         END-PERFORM
                     END-IF
                     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT
                         COMPUTE WS-SLOT = (WS-N - 1) * 49 + WS-LVL
                         COMPUTE WS-I = (WS-N - 1) * 1225 + WS-COL-G(WS-C) * 49 + WS-LVL
                         MOVE WS-E-VAL(WS-HASH, WS-SLOT) TO SG-G-VAL(WS-I)
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-PERFORM
         MOVE 1 TO DNG-ACTIVE
         MOVE WS-X0 TO DNG-X0
         MOVE WS-Z0 TO DNG-Z0
         SET DNG-PTR TO ADDRESS OF SG-GRID
         CALL "DENSITY-HULL" USING WS-ROOT WS-CI WS-CK WS-CJ WS-LO WS-HI
         EVALUATE TRUE
             WHEN WS-HI < WS-MINUS-SURE
                 CONTINUE
             WHEN OTHER
                 COMPUTE WS-TOP = -64 + 8 * WS-CJ + 7
                 PERFORM VARYING WS-Y FROM WS-TOP BY -1 UNTIL WS-Y < WS-TOP - 7 OR WS-FOUND = 1
                     CALL "DENSITY-NODE" USING WS-ROOT L-X WS-Y L-Z WS-D
                     CALL "FCMP-GT" USING WS-D WS-ZERO-F WS-GT
                     IF WS-GT = 1
                         MOVE WS-Y TO WS-SOLID-TOP
                         MOVE 1 TO WS-FOUND
                     END-IF
                 END-PERFORM
         END-EVALUATE
         MOVE 0 TO DNG-ACTIVE
         SUBTRACT 1 FROM WS-CJ
     END-PERFORM
     MOVE WS-SAVE-ACTIVE TO DNG-ACTIVE
     MOVE WS-SAVE-X0 TO DNG-X0
     MOVE WS-SAVE-Z0 TO DNG-Z0
     SET DNG-PTR TO WS-SAVE-PTR
*>   the heightmap predicate: stone, and for the world surface the fluid of the global picker
     CALL "AQ-PICKER" USING WS-SEA-Y WS-SEA WS-SEA-TYPE
     COMPUTE WS-H1 = WS-SOLID-TOP + 1
     IF WS-FOUND = 0
         MOVE -64 TO WS-H1
     END-IF
     COMPUTE WS-H0 = WS-SOLID-TOP + 1
     IF WS-FOUND = 0 OR WS-H0 < WS-SEA
         MOVE WS-SEA TO WS-H0
     END-IF
     COMPUTE WS-LVL = WG-LOAD-GEN + NZ-GEN
     MOVE WS-LVL TO WS-K-STAMP(WS-KSLOT)
     MOVE L-X TO WS-K-X(WS-KSLOT)
     MOVE L-Z TO WS-K-Z(WS-KSLOT)
     MOVE WS-H0 TO WS-K-H0(WS-KSLOT)
     MOVE WS-H1 TO WS-K-H1(WS-KSLOT)
     IF L-KIND = 1
         MOVE WS-H1 TO L-HEIGHT
     ELSE
         MOVE WS-H0 TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BASE-HEIGHT-RAW.
