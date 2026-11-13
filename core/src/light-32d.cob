*> The light engine of docs/protocol/32-light-engine.md, sections 5.2 and 5.3 (T0688): the sky-light engine (checkNode, updateSourcesInColumn,
*> the empty sections below a column edge, chunk start, setLightEnabled) and ChunkSkyLightSources (core/copy/L32.cpy: EN-LS is one table of 256
*> lowest source Y per chunk, indexed x + 16 z + 1; Integer.MIN_VALUE stands for "sources reach below the world").

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-LOWEST.
*> USING world x, z, default; gives getLowestSourceY of the column: the chunk's table value, the default when the chunk is not available (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-DEFAULT L-RESULT.
     MOVE L-DEFAULT TO L-RESULT
     COMPUTE WS-LX = FUNCTION MOD(L-X, 16)
     COMPUTE WS-LZ = FUNCTION MOD(L-Z, 16)
     COMPUTE WS-CX = (L-X - WS-LX) / 16
     COMPUTE WS-CZ = (L-Z - WS-LZ) / 16
     IF WS-CX >= -1 AND WS-CX <= 2 AND WS-CZ >= -1 AND WS-CZ <= 2
         COMPUTE WS-COL = (WS-CZ + 1) * 4 + WS-CX + 2
         IF EN-AVAIL(WS-COL) = 1
             MOVE EN-LS(WS-COL, WS-LX + 16 * WS-LZ + 1) TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-LOWEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-EDGE-OCC.
*> USING state above, state below; gives isEdgeOccluded: 1 when below's dampening is not 0, else faceShapeOccludes(occlusion shape of above toward
*> DOWN, occlusion shape of below toward UP) (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-FACE-A              BINARY-LONG.
 01 WS-FACE-B              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-BELOW L-OCCLUDED.
     MOVE 1 TO L-OCCLUDED
     IF EN-DAMP(L-BELOW + 1) = 0
         MOVE 0 TO WS-FACE-A WS-FACE-B
         CALL "L32-IS-EMPTY-SHAPE" USING L-ABOVE WS-EMPTY
         IF WS-EMPTY = 0
             MOVE EN-FACE(L-ABOVE + 1, 1) TO WS-FACE-A
         END-IF
         CALL "L32-IS-EMPTY-SHAPE" USING L-BELOW WS-EMPTY
         IF WS-EMPTY = 0
             MOVE EN-FACE(L-BELOW + 1, 2) TO WS-FACE-B
         END-IF
         CALL "L32-FACE-OCCLUDES" USING WS-FACE-A WS-FACE-B L-OCCLUDED
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-EDGE-OCC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-FILL.
*> USING chunk x, chunk z: ChunkSkyLightSources.fillFrom (5.3): a chunk without a non-air section has no ground (every entry the minimum); otherwise per
*> column scan down from the top of the highest non-air section (air above it) for the first occluded edge: the lowest source is the Y of the cell above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 01 WS-TOP                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-HERE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-COL = (L-CZ + 1) * 4 + L-CX + 2
     COMPUTE WS-BASE = (WS-COL - 1) * 16384
     MOVE -1 TO WS-TOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE WS-MINV TO EN-LS(WS-COL, WS-I)
     END-PERFORM
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 3
         IF EN-NONAIR((WS-COL - 1) * 4 + WS-S + 1) > 0
             MOVE WS-S TO WS-TOP
         END-IF
     END-PERFORM
     IF WS-TOP >= 0
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
             MOVE 0 TO WS-ABOVE WS-FOUND
             COMPUTE WS-Y = WS-TOP * 16 + 15
             PERFORM UNTIL WS-Y < 0 OR WS-FOUND = 1
                 MOVE EN-BLK(WS-BASE + WS-Y * 256 + WS-I + 1) TO WS-HERE
                 CALL "L32-SKY-EDGE-OCC" USING WS-ABOVE WS-HERE WS-OCCLUDED
                 IF WS-OCCLUDED = 1
                     MOVE 1 TO WS-FOUND
                     COMPUTE EN-LS(WS-COL, WS-I + 1) = WS-Y + 1
                 END-IF
                 MOVE WS-HERE TO WS-ABOVE
                 SUBTRACT 1 FROM WS-Y
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-FIND-BELOW.
*> USING x, y, z; gives findLowestSourceBelow (5.3): walk down from the cell until an occluded edge; the result is the Y of the cell above that
*> edge, or the minimum value when the walk reaches the cell below the world without one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-RESULT.
     MOVE WS-MINV TO L-RESULT
     CALL "L32-STATE-AT" USING L-X L-Y L-Z WS-ABOVE
     COMPUTE WS-Y = L-Y - 1
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-Y < -1 OR WS-DONE = 1
         CALL "L32-STATE-AT" USING L-X WS-Y L-Z WS-BELOW
         CALL "L32-SKY-EDGE-OCC" USING WS-ABOVE WS-BELOW WS-OCCLUDED
         IF WS-OCCLUDED = 1
             COMPUTE L-RESULT = WS-Y + 1
             MOVE 1 TO WS-DONE
         END-IF
         MOVE WS-BELOW TO WS-ABOVE
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM L32-SKY-FIND-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-STEP.
*> USING x, lower cell Y, z, column, table index (1 to 256); gives 1 when the entry changed: the edge between the cell above the lower cell and the lower cell
*> occluded and its Y above the entry sets the entry to that Y; open and its Y equal to the entry looks down for the next occluded edge (5.3 update).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-NY                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-LOWER L-Z L-COL L-INDEX L-CHANGED.
     MOVE 0 TO L-CHANGED
     COMPUTE WS-NY = L-LOWER + 1
     MOVE EN-LS(L-COL, L-INDEX) TO WS-CURRENT
     CALL "L32-STATE-AT" USING L-X WS-NY L-Z WS-ABOVE
     CALL "L32-STATE-AT" USING L-X L-LOWER L-Z WS-BELOW
     CALL "L32-SKY-EDGE-OCC" USING WS-ABOVE WS-BELOW WS-OCCLUDED
     EVALUATE TRUE
         WHEN WS-OCCLUDED = 1 AND WS-NY > WS-CURRENT
             MOVE WS-NY TO EN-LS(L-COL, L-INDEX)
             MOVE 1 TO L-CHANGED
         WHEN WS-OCCLUDED = 0 AND WS-NY = WS-CURRENT
             CALL "L32-SKY-FIND-BELOW" USING L-X L-LOWER L-Z EN-LS(L-COL, L-INDEX)
             MOVE 1 TO L-CHANGED
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-SKY-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-UPDATE.
*> USING x, y, z (a block changed, the new state already stored); gives ChunkSkyLightSources.update (5.3): false when y + 1 is below the entry, else the edge
*> between the changed cell and the cell above is tested, and when that changes nothing the edge to the cell below.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LOWER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CHANGED.
     MOVE 0 TO L-CHANGED
     COMPUTE WS-LX = FUNCTION MOD(L-X, 16)
     COMPUTE WS-LZ = FUNCTION MOD(L-Z, 16)
     COMPUTE WS-CX = (L-X - WS-LX) / 16
     COMPUTE WS-CZ = (L-Z - WS-LZ) / 16
     COMPUTE WS-COL = (WS-CZ + 1) * 4 + WS-CX + 2
     COMPUTE WS-INDEX = WS-LX + 16 * WS-LZ + 1
     IF L-Y + 1 >= EN-LS(WS-COL, WS-INDEX)
         CALL "L32-SKY-STEP" USING L-X L-Y L-Z WS-COL WS-INDEX L-CHANGED
         IF L-CHANGED = 0
             COMPUTE WS-LOWER = L-Y - 1
             CALL "L32-SKY-STEP" USING L-X WS-LOWER L-Z WS-COL WS-INDEX L-CHANGED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-UPDATE-COLUMN.
*> USING x, z, lowest source Y: updateSourcesInColumn (5.2): the removal step clears the cells below the new lowest source that still hold 15 (the top
*> one with REMOVE_TOP_SKY_SOURCE_ENTRY, the rest with REMOVE_SKY_SOURCE_ENTRY), then the addition step sets 15 from the lowest source up through the
*> cells that do not hold it, queueing ADD_SKY_SOURCE_ENTRY where a horizontal neighbour column has no source at that height or at the lowest source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 01 WS-MAXV                BINARY-LONG VALUE 2147483647.
 01 WS-LAYER               BINARY-LONG VALUE 2.
 01 WS-BSEC                BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-RM                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-NBR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KA                  BINARY-LONG.
 01 WS-KB                  BINARY-LONG.
 01 WS-SGN                 BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LEVEL-15            BINARY-LONG VALUE 15.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LOWEST               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-LOWEST.
     MOVE LY-LOWEST(2) TO WS-BSEC
     IF WS-BSEC NOT = WS-MAXV
         COMPUTE WS-BOTTOM = WS-BSEC * 16
         CALL "L32-LOCATE" USING L-X WS-ZERO L-Z WS-COL WS-SID WS-INDEX
         IF L-LOWEST > WS-BOTTOM
             COMPUTE WS-Y = L-LOWEST - 1
             MOVE 0 TO WS-DONE
             PERFORM UNTIL WS-DONE = 1
                 COMPUTE WS-RM = FUNCTION MOD(WS-Y, 16)
                 COMPUTE WS-SEC = (WS-Y - WS-RM) / 16
                 CALL "L32-STORES" USING WS-LAYER L-X WS-Y L-Z WS-STORES
                 MOVE 0 TO WS-LEVEL
                 IF WS-STORES = 1
                     CALL "L32-GET-STORED" USING WS-LAYER L-X WS-Y L-Z WS-LEVEL
                 END-IF
                 EVALUATE TRUE
                     WHEN WS-SEC < WS-BSEC
                         MOVE 1 TO WS-DONE
                     WHEN WS-STORES = 0
                         COMPUTE WS-Y = WS-SEC * 16 - 1
                     WHEN WS-LEVEL NOT = 15
                         MOVE 1 TO WS-DONE
                     WHEN OTHER
                         CALL "L32-SET-STORED" USING WS-LAYER L-X WS-Y L-Z WS-ZERO
                         MOVE 3 TO WS-WHICH
                         IF WS-Y = L-LOWEST - 1
                             MOVE 2 TO WS-WHICH
                         END-IF
                         CALL "L32-ENTRY-CONST" USING WS-WHICH WS-ENTRY
                         CALL "L32-PUSH-DEC" USING WS-LAYER L-X WS-Y L-Z WS-ENTRY
                         SUBTRACT 1 FROM WS-Y
                 END-EVALUATE
             END-PERFORM
         END-IF
*>       The highest lowest source of the four horizontal neighbour columns: west, east, north, south.
         MOVE WS-MINV TO WS-NBR
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
             DIVIDE WS-K BY 2 GIVING WS-KA REMAINDER WS-KB
             COMPUTE WS-SGN = 2 * WS-KB - 1
             COMPUTE WS-X = L-X + WS-SGN * (1 - WS-KA)
             COMPUTE WS-NZ = L-Z + WS-SGN * WS-KA
             CALL "L32-SKY-LOWEST" USING WS-X WS-NZ WS-MINV WS-N
             IF WS-N > WS-NBR
                 MOVE WS-N TO WS-NBR
             END-IF
         END-PERFORM
         MOVE WS-BOTTOM TO WS-Y
         IF L-LOWEST > WS-Y
             MOVE L-LOWEST TO WS-Y
         END-IF
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             COMPUTE WS-RM = FUNCTION MOD(WS-Y, 16)
             COMPUTE WS-SEC = (WS-Y - WS-RM) / 16
             MOVE 0 TO WS-STORES WS-LEVEL
             IF LY-TOPSET(2, WS-COL) = 1 AND WS-SEC < LY-TOP(2, WS-COL)
                 CALL "L32-STORES" USING WS-LAYER L-X WS-Y L-Z WS-STORES
                 IF WS-STORES = 1
                     CALL "L32-GET-STORED" USING WS-LAYER L-X WS-Y L-Z WS-LEVEL
                 END-IF
             END-IF
             EVALUATE TRUE
                 WHEN LY-TOPSET(2, WS-COL) = 0 OR WS-SEC >= LY-TOP(2, WS-COL)
                     MOVE 1 TO WS-DONE
                 WHEN WS-STORES = 0
                     COMPUTE WS-Y = (WS-SEC + 1) * 16
                 WHEN WS-LEVEL = 15
                     MOVE 1 TO WS-DONE
                 WHEN OTHER
                     CALL "L32-SET-STORED" USING WS-LAYER L-X WS-Y L-Z WS-LEVEL-15
                     IF WS-Y < WS-NBR OR WS-Y = L-LOWEST
                         MOVE 4 TO WS-WHICH
                         CALL "L32-ENTRY-CONST" USING WS-WHICH WS-ENTRY
                         CALL "L32-PUSH-INC" USING WS-LAYER L-X WS-Y L-Z WS-ENTRY
                     END-IF
                     ADD 1 TO WS-Y
             END-EVALUATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-UPDATE-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-CHECK.
*> USING x, y, z: SkyLightEngine.checkNode (5.2): the lowest source Y of the column when its light is enabled (else no sources) goes to
*> updateSourcesInColumn; nothing more when the section stores no light; a source cell queues REMOVE_SKY_SOURCE_ENTRY and ADD_SKY_SOURCE_ENTRY; else a
*> lit cell is cleared with decreaseAllDirections, a dark one pulls light in.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-MAXV                BINARY-LONG VALUE 2147483647.
 01 WS-LAYER               BINARY-LONG VALUE 2.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LOWEST              BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NOFLAG              BINARY-LONG VALUE 0.
 01 WS-DIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     MOVE WS-MAXV TO WS-LOWEST
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     IF LY-ON(2, WS-COL) = 1
         CALL "L32-SKY-LOWEST" USING L-X L-Z WS-MAXV WS-LOWEST
     END-IF
     IF WS-LOWEST NOT = WS-MAXV
         CALL "L32-SKY-UPDATE-COLUMN" USING L-X L-Z WS-LOWEST
     END-IF
     CALL "L32-STORES" USING WS-LAYER L-X L-Y L-Z WS-STORES
     IF WS-STORES = 1
         IF L-Y >= WS-LOWEST
             MOVE 3 TO WS-WHICH
             CALL "L32-ENTRY-CONST" USING WS-WHICH WS-ENTRY
             CALL "L32-PUSH-DEC" USING WS-LAYER L-X L-Y L-Z WS-ENTRY
             MOVE 4 TO WS-WHICH
             CALL "L32-ENTRY-CONST" USING WS-WHICH WS-ENTRY
             CALL "L32-PUSH-INC" USING WS-LAYER L-X L-Y L-Z WS-ENTRY
         ELSE
             CALL "L32-GET-STORED" USING WS-LAYER L-X L-Y L-Z WS-S
             IF WS-S > 0
                 CALL "L32-SET-STORED" USING WS-LAYER L-X L-Y L-Z WS-ZERO
                 CALL "L32-ENTRY" USING WS-KIND WS-S WS-NOFLAG WS-DIR WS-ENTRY
             ELSE
                 MOVE 1 TO WS-WHICH
                 CALL "L32-ENTRY-CONST" USING WS-WHICH WS-ENTRY
             END-IF
             CALL "L32-PUSH-DEC" USING WS-LAYER L-X L-Y L-Z WS-ENTRY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-EMPTY-BELOW.
*> USING x, y, z of a dequeued cell P; gives countEmptySectionsBelowIfAtBorder (5.2): 0 unless Y is a section bottom and P is on its section's x or z edge,
*> else the number of consecutive sections directly below that store no light but have light data at or below them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-COUNT.
     MOVE 0 TO L-COUNT
     COMPUTE WS-LX = FUNCTION MOD(L-X, 16)
     COMPUTE WS-LY = FUNCTION MOD(L-Y, 16)
     COMPUTE WS-LZ = FUNCTION MOD(L-Z, 16)
     IF WS-LY = 0 AND (WS-LX = 0 OR WS-LX = 15 OR WS-LZ = 0 OR WS-LZ = 15)
         CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
         COMPUTE WS-SEC = L-Y / 16 - 1
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             IF WS-SEC < LY-LOWEST(2)
                 MOVE 1 TO WS-DONE
             ELSE
                 COMPUTE WS-SID = (WS-COL - 1) * 6 + WS-SEC + 2
                 IF LY-WP(2, WS-SID) = 1
                     MOVE 1 TO WS-DONE
                 ELSE
                     ADD 1 TO L-COUNT
                     SUBTRACT 1 FROM WS-SEC
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-EMPTY-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-FROM-EMPTY.
*> USING neighbour x, y, z, direction, level, increase (1) or decrease (0), k from L32-EMPTY-BELOW: propagateFromEmptySections (5.2): when k > 0 and the step
*> crossed a section column edge (NORTH z 15, SOUTH z 0, WEST x 15, EAST x 0 of the neighbour), each of the k sections below the neighbour's section that stores
*> light in the neighbour's column gets the level (increase, queueing increaseSkipOneDirection with from-empty-shape) or 0 (decrease, queueing a decrease)
*> at all 16 Y values from the top.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CROSS               BINARY-LONG.
 01 WS-RM                  BINARY-LONG.
 01 WS-NSEC                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LOW-Y               BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-INCREASE             BINARY-LONG.
 01 L-K                    BINARY-LONG.
 PROCEDURE DIVISION USING L-NX L-NY L-NZ L-DIR L-LEVEL L-INCREASE L-K.
     IF L-K > 0
         COMPUTE WS-LX = FUNCTION MOD(L-NX, 16)
         COMPUTE WS-LZ = FUNCTION MOD(L-NZ, 16)
         MOVE 0 TO WS-CROSS
         EVALUATE L-DIR
             WHEN 2
                 IF WS-LZ = 15
                     MOVE 1 TO WS-CROSS
                 END-IF
             WHEN 3
                 IF WS-LZ = 0
                     MOVE 1 TO WS-CROSS
                 END-IF
             WHEN 4
                 IF WS-LX = 15
                     MOVE 1 TO WS-CROSS
                 END-IF
             WHEN 5
                 IF WS-LX = 0
                     MOVE 1 TO WS-CROSS
                 END-IF
         END-EVALUATE
         IF WS-CROSS = 1
             CALL "L32-DIRECTION" USING L-DIR WS-DX WS-DY WS-DZ WS-OPP
             COMPUTE WS-RM = FUNCTION MOD(L-NY, 16)
             COMPUTE WS-NSEC = (L-NY - WS-RM) / 16
             COMPUTE WS-LAST = WS-NSEC - L-K
             COMPUTE WS-S = WS-NSEC - 1
             CALL "L32-LOCATE" USING L-NX L-NY L-NZ WS-COL WS-SID WS-INDEX
             PERFORM UNTIL WS-S < WS-LAST
                 COMPUTE WS-SID = (WS-COL - 1) * 6 + WS-S + 2
                 IF WS-S >= -1 AND LY-WP(2, WS-SID) = 1
                     COMPUTE WS-Y = WS-S * 16 + 15
                     PERFORM 16 TIMES
                         IF L-INCREASE = 1
                             CALL "L32-SET-STORED" USING WS-LAYER L-NX WS-Y L-NZ L-LEVEL
                             IF L-LEVEL > 1
                                 MOVE 4 TO WS-KIND
                                 CALL "L32-ENTRY" USING WS-KIND L-LEVEL WS-ONE WS-OPP WS-ENTRY
                                 CALL "L32-PUSH-INC" USING WS-LAYER L-NX WS-Y L-NZ WS-ENTRY
                             END-IF
                         ELSE
                             CALL "L32-SET-STORED" USING WS-LAYER L-NX WS-Y L-NZ WS-ZERO
                             MOVE 2 TO WS-KIND
                             CALL "L32-ENTRY" USING WS-KIND L-LEVEL WS-ZERO WS-OPP WS-ENTRY
                             CALL "L32-PUSH-DEC" USING WS-LAYER L-NX WS-Y L-NZ WS-ENTRY
                         END-IF
                         SUBTRACT 1 FROM WS-Y
                     END-PERFORM
                 END-IF
                 SUBTRACT 1 FROM WS-S
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-FROM-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHUNK-START-SKY.
*> USING chunk x, chunk z: SkyLightEngine.propagateLightSources (5.2): enables light for the column, then from the highest storing section down to the lowest
*> section ever initialised: a section without a layer is passed over; for each of its 256 columns with a lowest source ls at or below the section top, the
*> cells from the top down to max(section bottom, ls) are set to 15 and an increaseSkySourceInDirections entry is queued where Y = ls (down) or Y is below a
*> neighbour column's lowest source (that direction); the next section down is processed only while some column's source continues below this one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 2.
 01 WS-FIFTEEN             BINARY-LONG VALUE 15.
 01 WS-SEC                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-LSN                 BINARY-LONG.
 01 WS-LSS                 BINARY-LONG.
 01 WS-LSW                 BINARY-LONG.
 01 WS-LSE                 BINARY-LONG.
 01 WS-MAXN                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 01 WS-FLAGS.
    05 WS-DOWN             BINARY-LONG.
    05 WS-NORTH            BINARY-LONG.
    05 WS-SOUTH            BINARY-LONG.
    05 WS-WEST             BINARY-LONG.
    05 WS-EAST             BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-COL = (L-CZ + 1) * 4 + L-CX + 2
     MOVE 1 TO LY-ON(2, WS-COL)
     MOVE LY-LOWEST(2) TO WS-BOTTOM
     MOVE LY-LOWEST(2) TO WS-SEC
     IF LY-TOPSET(2, WS-COL) = 1
         MOVE LY-TOP(2, WS-COL) TO WS-SEC
     END-IF
     SUBTRACT 1 FROM WS-SEC
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-SEC < WS-BOTTOM OR WS-STOP = 1
         COMPUTE WS-SID = (WS-COL - 1) * 6 + WS-SEC + 2
         IF LY-WP(2, WS-SID) = 1
             COMPUTE WS-SB = WS-SEC * 16
             COMPUTE WS-ST = WS-SB + 15
             MOVE 0 TO WS-MARK
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
                 MOVE EN-LS(WS-COL, WS-I + 1) TO WS-LS
                 IF WS-LS <= WS-ST
                     COMPUTE WS-LZ = WS-I / 16
                     COMPUTE WS-LX = WS-I - WS-LZ * 16
                     COMPUTE WS-X = L-CX * 16 + WS-LX
                     COMPUTE WS-Z = L-CZ * 16 + WS-LZ
                     COMPUTE WS-NZ = WS-Z - 1
                     CALL "L32-SKY-LOWEST" USING WS-X WS-NZ WS-MINV WS-LSN
                     COMPUTE WS-NZ = WS-Z + 1
                     CALL "L32-SKY-LOWEST" USING WS-X WS-NZ WS-MINV WS-LSS
                     COMPUTE WS-NX = WS-X - 1
                     CALL "L32-SKY-LOWEST" USING WS-NX WS-Z WS-MINV WS-LSW
                     COMPUTE WS-NX = WS-X + 1
                     CALL "L32-SKY-LOWEST" USING WS-NX WS-Z WS-MINV WS-LSE
                     MOVE WS-LSN TO WS-MAXN
                     IF WS-LSS > WS-MAXN
                         MOVE WS-LSS TO WS-MAXN
                     END-IF
                     IF WS-LSW > WS-MAXN
                         MOVE WS-LSW TO WS-MAXN
                     END-IF
                     IF WS-LSE > WS-MAXN
                         MOVE WS-LSE TO WS-MAXN
                     END-IF
                     MOVE WS-SB TO WS-LOW
                     IF WS-LS > WS-LOW
                         MOVE WS-LS TO WS-LOW
                     END-IF
                     PERFORM VARYING WS-Y FROM WS-ST BY -1 UNTIL WS-Y < WS-LOW
                         CALL "L32-SET-STORED" USING WS-LAYER WS-X WS-Y WS-Z WS-FIFTEEN
                         IF WS-Y = WS-LS OR WS-Y < WS-MAXN
                             MOVE 0 TO WS-DOWN WS-NORTH WS-SOUTH WS-WEST WS-EAST
                             IF WS-Y = WS-LS
                                 MOVE 1 TO WS-DOWN
                             END-IF
                             IF WS-Y < WS-LSN
                                 MOVE 1 TO WS-NORTH
                             END-IF
                             IF WS-Y < WS-LSS
                                 MOVE 1 TO WS-SOUTH
                             END-IF
                             IF WS-Y < WS-LSW
                                 MOVE 1 TO WS-WEST
                             END-IF
                             IF WS-Y < WS-LSE
                                 MOVE 1 TO WS-EAST
                             END-IF
                             CALL "L32-ENTRY-SKY" USING WS-DOWN WS-NORTH WS-SOUTH WS-WEST WS-EAST WS-ENTRY
                             CALL "L32-PUSH-INC" USING WS-LAYER WS-X WS-Y WS-Z WS-ENTRY
                         END-IF
                     END-PERFORM
                     IF WS-LS < WS-SB
                         MOVE 1 TO WS-MARK
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-MARK = 0
                 MOVE 1 TO WS-STOP
             END-IF
         END-IF
         SUBTRACT 1 FROM WS-SEC
     END-PERFORM
     GOBACK.
 END PROGRAM L32-CHUNK-START-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SET-LIGHT-ENABLED.
*> USING chunk x, chunk z, flag: LevelLightEngine.setLightEnabled (5.2, 6.5): sets the column flag of the block engine and of the sky engine (when it exists);
*> enabling the sky column also fills with 15 every writable layer that is all zero from the top storing section down to max(bottom, S), S = section of
*> H - 1 plus 1, H the highest lowest-source Y of the chunk (an empty chunk, H the minimum value, scans down to the bottom).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-FLAG.
     COMPUTE WS-COL = (L-CZ + 1) * 4 + L-CX + 2
     MOVE L-FLAG TO LY-ON(1, WS-COL)
     IF EN-SKY-ON = 1
         MOVE L-FLAG TO LY-ON(2, WS-COL)
         IF L-FLAG = 1
             MOVE LY-LOWEST(2) TO WS-TOP WS-BOTTOM
             IF LY-TOPSET(2, WS-COL) = 1
                 MOVE LY-TOP(2, WS-COL) TO WS-TOP
             END-IF
             MOVE WS-MINV TO WS-H
             IF EN-AVAIL(WS-COL) = 1
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
                     IF EN-LS(WS-COL, WS-I) > WS-H
                         MOVE EN-LS(WS-COL, WS-I) TO WS-H
                     END-IF
                 END-PERFORM
             END-IF
             MOVE WS-BOTTOM TO WS-S
             IF WS-H NOT = WS-MINV
                 COMPUTE WS-RM = FUNCTION MOD(WS-H - 1, 16)
                 COMPUTE WS-S = (WS-H - 1 - WS-RM) / 16 + 1
             END-IF
             MOVE WS-BOTTOM TO WS-LO
             IF WS-S > WS-LO
                 MOVE WS-S TO WS-LO
             END-IF
             COMPUTE WS-SEC = WS-TOP - 1
             PERFORM UNTIL WS-SEC < WS-LO
                 COMPUTE WS-SID = (WS-COL - 1) * 6 + WS-SEC + 2
                 IF LY-WP(2, WS-SID) = 1 AND LY-WD(2, WS-SID) = LOW-VALUES
                     MOVE ALL X"FF" TO LY-WD(2, WS-SID)
                     MOVE 1 TO LY-CH(2, WS-SID)
                 END-IF
                 SUBTRACT 1 FROM WS-SEC
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SET-LIGHT-ENABLED.
