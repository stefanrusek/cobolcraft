*> SKY-STOPGAP: a temporary client-side stand-in for sky light. REMOVE WHEN CC-0007 (the real light engine) LANDS.
*>
*> The core sends block light but no sky light for freshly generated standard chunks, so every surface would
*> mesh at the 0.1 floor. For a dimension that has sky light (PL-HAS-SKY), a block section whose sky light
*> array is absent or all zero is treated at mesh time as: sky 15 for cells at or above the column's surface,
*> 0 below. The surface of a column is one above its topmost opaque block, computed here from the replica
*> (the heightmaps of the chunk packet are not kept). A section with any nonzero sky light is used as it is,
*> and the stored light is never changed: MESH-CELL asks SKY-STOPGAP-CELL only for the value it meshes with.
*> To remove: delete this file, its two calls in mesher.cob (MESH-SECTION, MESH-CELL), SKG-STATE in CLSTATE.cpy
*> and test_sky_stopgap.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-ROW.
*> USING CLIENT-STATE, row: adds an entry for the row to SKG-STATE when any of its block sections has no sky
*> light data (SKY-STOPGAP-PREPARE calls it for at most five rows).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 B-CELLS                PIC X(CE-CHUNK-BYTES) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     MOVE SKG-COUNT TO WS-G
     ADD 1 TO WS-G
     MOVE 0 TO WS-ANY WS-TOP
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
         COMPUTE WS-BASE = WS-S * CE-LIGHT-BYTES + 1
         MOVE 0 TO SKG-FAKE(WS-G, WS-S)
         IF CE-SKYS(WS-BASE:CE-LIGHT-BYTES) = LOW-VALUES
             MOVE 1 TO SKG-FAKE(WS-G, WS-S)
             MOVE 1 TO WS-ANY
         END-IF
         SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
         COMPUTE WS-BASE = (WS-S - 1) * 8192 + 1
         IF B-CELLS(WS-BASE:8192) NOT = LOW-VALUES
             MOVE WS-S TO WS-TOP
         END-IF
     END-PERFORM
     IF WS-ANY = 0
         GOBACK
     END-IF
     ADD 1 TO SKG-COUNT
     COMPUTE WS-FROM = WS-TOP * 16 - 1
     MOVE L-ROW TO SKG-ROW(WS-G)
*>   The surface of each column: one above its topmost opaque block, scanning down from the highest
*>   section that has any block.
     PERFORM VARYING WS-COLUMN FROM 1 BY 1 UNTIL WS-COLUMN > 256
         MOVE 0 TO SKG-SURF(WS-G, WS-COLUMN)
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-Y FROM WS-FROM BY -1 UNTIL WS-Y < 0 OR WS-DONE = 1
             COMPUTE WS-K = WS-Y * 256 + WS-COLUMN
             IF ST-OPAQUE(CE-STATE(WS-K) + 1) = 1
                 COMPUTE SKG-SURF(WS-G, WS-COLUMN) = WS-Y + 1
                 MOVE 1 TO WS-DONE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-STOPGAP-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-PREPARE.
*> USING CLIENT-STATE, row, neighbour rows (west, east, north, south; 0 = not loaded): SKG-STATE for the
*> section about to be meshed, which reads light from those five rows. Nothing when the dimension has no sky.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NEIGHBOURS.
    05 L-NROW              BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NEIGHBOURS.
     MOVE 0 TO SKG-COUNT
     IF PL-HAS-SKY = 1
         CALL "SKY-STOPGAP-ROW" USING CLIENT-STATE L-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             CALL "SKY-STOPGAP-ROW" USING CLIENT-STATE L-NROW(WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SKY-STOPGAP-PREPARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-CELL.
*> USING CLIENT-STATE, row, x, y, z (x and z local 0 to 15, y from min_y), sky light (in: the stored value,
*> out: the value to mesh with): replaced by 15 or 0 when the row has an entry whose section has no sky data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-Z L-SKY.
     COMPUTE WS-S = L-Y / 16 + 1
     COMPUTE WS-COLUMN = L-Z * 16 + L-X + 1
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > SKG-COUNT
         IF SKG-ROW(WS-G) = L-ROW AND SKG-FAKE(WS-G, WS-S) = 1
             MOVE 0 TO L-SKY
             IF L-Y >= SKG-SURF(WS-G, WS-COLUMN)
                 MOVE 15 TO L-SKY
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-STOPGAP-CELL.
