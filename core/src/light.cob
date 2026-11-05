*> The stand-in light policy (standin-content §5.2; docs/protocol/09-cobolcraft-profile.md §3.4
*> rule 4) over the chunk cache (world.cob, CHUNKMEM.cpy). Sky light: 15 in every cell above its
*> column's topmost non-void block, 0 at or below it; no sideways spreading. Block light: a source of
*> level L (SB-LIGHT) has L, a non-opaque cell has L minus the length of the shortest face-adjacent
*> path from the source through non-opaque cells (never below 0), opaque cells other than sources
*> have 0, and the highest level from any source wins. Light never reaches 15 blocks from its source,
*> so a chunk's block light depends only on the sources of its 3 x 3 chunk neighbourhood; those
*> chunks are generated (not lit) to find them, and the spread walks generated cells only.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-CHUNK.
*> USING row (BINARY-LONG): computes the sky and block light of that cached chunk and sets CK-LIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "LIGHT-SKY" USING L-ROW
     CALL "LIGHT-BLOCK" USING L-ROW
     MOVE 1 TO CK-LIT(L-ROW)
     GOBACK.
 END PROGRAM LIGHT-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-BLOCK-CHANGED.
*> USING row (BINARY-LONG) of a lit chunk in which a block changed: recomputes its sky light and the
*> block light of every lit chunk of its 3 x 3 neighbourhood (a change can only alter block light
*> within 14 blocks of itself). Unloaded and unlit chunks are left alone: they are lit on access.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "LIGHT-SKY" USING L-ROW
     MOVE CK-DIM(L-ROW) TO WS-DIM
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0 AND CK-LIT(WS-ROW) = 1
                 CALL "LIGHT-BLOCK" USING WS-ROW
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-BLOCK-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SKY.
*> USING row (BINARY-LONG): the sky light of that cached chunk. Whole layers are set at once up to
*> the lowest column top, then each column from there to its own top.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CHUNKMEM.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-MIN                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     CALL "WORLD-COLUMN-TOPS" USING L-ROW WS-TOPS
     MOVE 255 TO WS-MIN
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         IF WS-TOP(WS-C) < WS-MIN
             MOVE WS-TOP(WS-C) TO WS-MIN
         END-IF
     END-PERFORM
     MOVE ALL X"0F" TO CM-SKYS
     COMPUTE WS-LENGTH = (WS-MIN + 1) * 256
     IF WS-LENGTH > 0
         MOVE LOW-VALUES TO CM-SKYS(1:WS-LENGTH)
     END-IF
     COMPUTE WS-LOW = WS-MIN + 1
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         PERFORM VARYING WS-Y FROM WS-LOW BY 1 UNTIL WS-Y > WS-TOP(WS-C)
             MOVE 0 TO CM-SKY(WS-Y * 256 + WS-C)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-BLOCK.
*> USING row (BINARY-LONG): the block light of that cached chunk, from every light source of its
*> 3 x 3 chunk neighbourhood that can reach it (only sections whose CK-SOURCES count is above 0 are
*> scanned for sources).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKS.
 COPY CHUNKMEM.
 COPY CHUNKMEM REPLACING LEADING ==CM-== BY ==CX-==.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FAR-X               BINARY-LONG.
 01 WS-FAR-Z               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     MOVE LOW-VALUES TO CM-BLOCKS
     MOVE CK-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-X0 = CK-X(L-ROW) * 16
     COMPUTE WS-Z0 = CK-Z(L-ROW) * 16
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
             SET ADDRESS OF CX-CHUNK TO CK-ADDR(WS-ROW)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
                 IF CK-SOURCES(WS-ROW, WS-S) > 0
                     COMPUTE WS-LAST = WS-S * 4096
                     COMPUTE WS-FIRST = WS-LAST - 4095
                     PERFORM VARYING WS-CELL FROM WS-FIRST BY 1 UNTIL WS-CELL > WS-LAST
                         MOVE SB-LIGHT(CX-STATE(WS-CELL) + 1) TO WS-LEVEL
                         IF WS-LEVEL > 0
                             COMPUTE WS-Y = (WS-CELL - 1) / 256
                             COMPUTE WS-REST = WS-CELL - 1 - WS-Y * 256
                             COMPUTE WS-Z = WS-REST / 16
                             COMPUTE WS-X = WS-CX * 16 + WS-REST - WS-Z * 16
                             COMPUTE WS-Z = WS-CZ * 16 + WS-Z
*>                           Taxicab distance from the source to the nearest cell of this chunk.
                             MOVE 0 TO WS-FAR-X WS-FAR-Z
                             IF WS-X < WS-X0
                                 COMPUTE WS-FAR-X = WS-X0 - WS-X
                             END-IF
                             IF WS-X > WS-X0 + 15
                                 COMPUTE WS-FAR-X = WS-X - WS-X0 - 15
                             END-IF
                             IF WS-Z < WS-Z0
                                 COMPUTE WS-FAR-Z = WS-Z0 - WS-Z
                             END-IF
                             IF WS-Z > WS-Z0 + 15
                                 COMPUTE WS-FAR-Z = WS-Z - WS-Z0 - 15
                             END-IF
                             IF WS-FAR-X + WS-FAR-Z < WS-LEVEL
                                 CALL "LIGHT-SPREAD" USING L-ROW WS-X WS-Y WS-Z WS-LEVEL
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SPREAD.
*> USING target row, source x, y, z (world x and z, cell y), level L (BINARY-LONG): breadth-first
*> spread of one source's light through non-opaque cells, raising the block light of the cells that
*> lie in the target chunk to the level reached there. Cells are visited at most once (a stamp per
*> cell of the 31 x 31 x 31 window around the source); chunks the spread enters are generated when
*> missing (WORLD-CHUNK-LOAD), the last one looked up is remembered.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKS.
 COPY CHUNKMEM.
 COPY CHUNKMEM REPLACING LEADING ==CM-== BY ==CX-==.
 01 WS-STAMP-ID            BINARY-LONG VALUE 0.
 01 WS-STAMPS.
    05 WS-STAMP            BINARY-LONG OCCURS 29791 TIMES VALUE 0.
 01 WS-QUEUE.
    05 WS-Q OCCURS 29791 TIMES.
       10 WS-QX            BINARY-LONG.
       10 WS-QY            BINARY-LONG.
       10 WS-QZ            BINARY-LONG.
       10 WS-QL            BINARY-LONG.
 01 WS-STEPS.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 6 TIMES.
       10 WS-STEP-X        BINARY-LONG.
       10 WS-STEP-Y        BINARY-LONG.
       10 WS-STEP-Z        BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEEN-CX             BINARY-LONG.
 01 WS-SEEN-CZ             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-LEVEL.
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-X0 = CK-X(L-ROW) * 16
     COMPUTE WS-Z0 = CK-Z(L-ROW) * 16
     MOVE 2147483647 TO WS-SEEN-CX
     ADD 1 TO WS-STAMP-ID
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE L-X TO WS-QX(1)
     MOVE L-Y TO WS-QY(1)
     MOVE L-Z TO WS-QZ(1)
     MOVE L-LEVEL TO WS-QL(1)
     MOVE WS-STAMP-ID TO WS-STAMP(15 + 15 * 31 + 15 * 961 + 1)
     PERFORM UNTIL WS-HEAD > WS-TAIL
         MOVE WS-QX(WS-HEAD) TO WS-X
         MOVE WS-QY(WS-HEAD) TO WS-Y
         MOVE WS-QZ(WS-HEAD) TO WS-Z
         MOVE WS-QL(WS-HEAD) TO WS-L
         ADD 1 TO WS-HEAD
         IF WS-X >= WS-X0 AND WS-X <= WS-X0 + 15 AND WS-Z >= WS-Z0 AND WS-Z <= WS-Z0 + 15
             COMPUTE WS-CELL = WS-Y * 256 + (WS-Z - WS-Z0) * 16 + WS-X - WS-X0 + 1
             IF CM-BLOCK(WS-CELL) < WS-L
                 MOVE WS-L TO CM-BLOCK(WS-CELL)
             END-IF
         END-IF
         IF WS-L > 1
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                 COMPUTE WS-NY = WS-Y + WS-STEP-Y(WS-D)
                 IF WS-NY >= 0 AND WS-NY <= 255
                     COMPUTE WS-NX = WS-X + WS-STEP-X(WS-D)
                     COMPUTE WS-NZ = WS-Z + WS-STEP-Z(WS-D)
                     COMPUTE WS-W = WS-NX - L-X + 15 + (WS-NZ - L-Z + 15) * 31
                         + (WS-NY - L-Y + 15) * 961 + 1
                     IF WS-STAMP(WS-W) NOT = WS-STAMP-ID
                         MOVE WS-STAMP-ID TO WS-STAMP(WS-W)
*>                       Chunk of (nx, nz): floor division by 16.
                         IF WS-NX >= 0
                             COMPUTE WS-CX = WS-NX / 16
                         ELSE
                             COMPUTE WS-CX = (WS-NX - 15) / 16
                         END-IF
                         IF WS-NZ >= 0
                             COMPUTE WS-CZ = WS-NZ / 16
                         ELSE
                             COMPUTE WS-CZ = (WS-NZ - 15) / 16
                         END-IF
                         IF WS-CX NOT = WS-SEEN-CX OR WS-CZ NOT = WS-SEEN-CZ
                             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
                             SET ADDRESS OF CX-CHUNK TO CK-ADDR(WS-ROW)
                             MOVE WS-CX TO WS-SEEN-CX
                             MOVE WS-CZ TO WS-SEEN-CZ
                         END-IF
                         COMPUTE WS-CELL = WS-NY * 256 + (WS-NZ - WS-CZ * 16) * 16
                             + WS-NX - WS-CX * 16 + 1
                         IF SB-OPAQUE(CX-STATE(WS-CELL) + 1) = 0
                             ADD 1 TO WS-TAIL
                             MOVE WS-NX TO WS-QX(WS-TAIL)
                             MOVE WS-NY TO WS-QY(WS-TAIL)
                             MOVE WS-NZ TO WS-QZ(WS-TAIL)
                             COMPUTE WS-QL(WS-TAIL) = WS-L - 1
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SPREAD.
