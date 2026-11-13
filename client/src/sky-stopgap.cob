*> SKY-STOPGAP: a temporary client-side stand-in for sky light. REMOVE WHEN CC-0007 (the real light engine) LANDS.
*>
*> The core sends block light but sky light only in part for freshly generated standard chunks (all 15 from
*> sea level up, a layer at sea level, zero below), so most surfaces would mesh at the 0.1 floor. For a dimension
*> that has sky light (PL-HAS-SKY), a cell whose stored sky light is 0 is read, by the mesher and by WORLD-CELL
*> (which entities read), as: 15 at or above the column's surface, 0 below; where fluid lies above the surface, the
*> sky light falls by one for every cell below the fluid's top (water darkens with depth), to 0. A stored value
*> above 0 is used as it is, and the stored light is never changed. The surface of a column is one above its
*> topmost opaque block, computed here from the replica (the heightmaps of the chunk packet are not kept) once for
*> a row and kept in WR-SURF and WR-WTOP of the row until its blocks change (WORLD-ROW-NEW and WORLD-BLOCK-SET
*> clear WR-SURF-OK): the scan is not repeated for each section meshed, so a chunk is lit as soon as its sections
*> are meshed. Daylight (the dark of night) is the shader's: it scales the sky term of the mesh, so nothing here
*> changes with the time of day.
*> To remove: delete this file, its calls in mesher.cob (MESH-CELL) and mesher-fluid.cob (MF-AT), its call in world-replica.cob (WORLD-CELL), the
*> WR-SURF fields in CLSTATE.cpy, the resets in WORLD-ROW-NEW and WORLD-BLOCK-SET, and test_sky_stopgap.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-SURFACE.
*> USING CLIENT-STATE, row (not 0): WR-SURF and WR-WTOP of the row, unless they are current (WR-SURF-OK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-FULL                PIC 9 OCCURS 24 TIMES.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-YBOTTOM             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-WTOP                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 B-CELLS                PIC X(CE-CHUNK-BYTES) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF WR-SURF-OK(L-ROW) = 1
         GOBACK
     END-IF
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
     MOVE 0 TO WS-TOP
*>   The sections that hold any block (an all-air section is skipped for every column).
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
         MOVE 0 TO WS-FULL(WS-S)
         COMPUTE WS-BASE = (WS-S - 1) * 8192 + 1
         IF B-CELLS(WS-BASE:8192) NOT = LOW-VALUES
             MOVE 1 TO WS-FULL(WS-S)
             MOVE WS-S TO WS-TOP
         END-IF
     END-PERFORM
*>   The surface of each column: one above its topmost opaque block, scanning down from the highest
*>   section that has any block; the top of the fluid met on the way, if any.
     PERFORM VARYING WS-COLUMN FROM 1 BY 1 UNTIL WS-COLUMN > 256
         MOVE 0 TO WS-SURF WS-WTOP WS-DONE
         PERFORM VARYING WS-S FROM WS-TOP BY -1 UNTIL WS-S < 1 OR WS-DONE = 1
             IF WS-FULL(WS-S) = 1
                 COMPUTE WS-Y = WS-S * 16 - 1
                 COMPUTE WS-YBOTTOM = WS-S * 16 - 16
                 PERFORM UNTIL WS-Y < WS-YBOTTOM OR WS-DONE = 1
                     COMPUTE WS-K = WS-Y * 256 + WS-COLUMN
                     MOVE CE-STATE(WS-K) TO WS-STATE
                     EVALUATE TRUE
                         WHEN ST-OPAQUE(WS-STATE + 1) = 1
                             COMPUTE WS-SURF = WS-Y + 1
                             MOVE 1 TO WS-DONE
                         WHEN ST-FLUID(WS-STATE + 1) > 0 AND WS-WTOP = 0
                             COMPUTE WS-WTOP = WS-Y + 1
                     END-EVALUATE
                     SUBTRACT 1 FROM WS-Y
                 END-PERFORM
             END-IF
         END-PERFORM
         MOVE WS-SURF TO WR-SURF(L-ROW, WS-COLUMN)
         MOVE WS-WTOP TO WR-WTOP(L-ROW, WS-COLUMN)
     END-PERFORM
     MOVE 1 TO WR-SURF-OK(L-ROW)
     GOBACK.
 END PROGRAM SKY-STOPGAP-SURFACE.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-LIGHT.
*> USING CLIENT-STATE, row (0 = not loaded), x, y, z (x and z local 0 to 15, y from min_y), sky light (in: the stored
*> value, out: the value to use): MESH-CELL's and WORLD-CELL's use. The assumed value (see the header) when the dimension
*> has sky light and the stored value is 0; else the stored value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-WTOP                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-Z L-SKY.
     IF PL-HAS-SKY = 0 OR L-ROW = 0 OR L-SKY > 0
         GOBACK
     END-IF
     IF WR-SURF-OK(L-ROW) = 0
         CALL "SKY-STOPGAP-SURFACE" USING CLIENT-STATE L-ROW
     END-IF
     COMPUTE WS-COLUMN = L-Z * 16 + L-X + 1
     MOVE WR-SURF(L-ROW, WS-COLUMN) TO WS-SURF
     MOVE WR-WTOP(L-ROW, WS-COLUMN) TO WS-WTOP
     MOVE 15 TO L-SKY
     EVALUATE TRUE
         WHEN L-Y < WS-SURF
             MOVE 0 TO L-SKY
         WHEN L-Y < WS-WTOP
             COMPUTE WS-DEPTH = WS-WTOP - L-Y
             IF WS-DEPTH > 15
                 MOVE 15 TO WS-DEPTH
             END-IF
             COMPUTE L-SKY = 15 - WS-DEPTH
     END-EVALUATE
     GOBACK.
 END PROGRAM SKY-STOPGAP-LIGHT.
