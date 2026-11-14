*> SKY-STOPGAP: a temporary client-side stand-in for sky light. REMOVE WHEN CC-0007 (the real light engine) LANDS.
*>
*> The core sends block light but sky light only in part for freshly generated standard chunks (all 15 from
*> sea level up, a layer at sea level, zero below), so most surfaces would mesh at the 0.1 floor. For a dimension
*> that has sky light (PL-HAS-SKY), a cell whose stored sky light is 0 is read, by the mesher and by WORLD-CELL
*> (which entities read), as: 15 at or above the column's surface, 0 below; where fluid lies above the surface, the
*> sky light falls by one for every cell below the fluid's top (water darkens with depth), to 0. A stored value
*> above 0 is used as it is, and the stored light is never changed. The surface of a column is one above its
*> topmost opaque block, computed here from the replica (the heightmaps of the chunk packet are not kept) once for
*> a row and kept in WR-SURF and WR-WTOP of the row (WORLD-ROW-NEW clears WR-SURF-OK; a block set scans only its
*> column again, SKY-STOPGAP-RESURFACE, and has the sections between the old and new levels meshed again): the scan is not repeated for each section meshed, so a chunk is lit as soon as its sections
*> are meshed. Daylight (the dark of night) is the shader's: it scales the sky term of the mesh, so nothing here
*> changes with the time of day.
*> To remove: delete this file, its calls in mesher.cob (MESH-CELL) and mesher-fluid.cob (MF-AT), its call in world-replica.cob (WORLD-CELL), the
*> WR-SURF fields in CLSTATE.cpy, the reset in WORLD-ROW-NEW and the call in WORLD-BLOCK-SET, and test_sky_stopgap.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-SECTIONS.
*> USING CLIENT-STATE, row (not 0), full out (24 PIC 9: 1 = section s holds any block), top out (BINARY-LONG: the highest
*> such section, 0 for none): the sections an all-air section lets a column scan skip.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 B-CELLS                PIC X(CE-CHUNK-BYTES) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-FULL.
    05 L-FULL-S            PIC 9 OCCURS 24 TIMES.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-FULL L-TOP.
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
     MOVE 0 TO L-TOP
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE 0 TO L-FULL-S(WS-S)
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
         COMPUTE WS-BASE = (WS-S - 1) * 8192 + 1
         IF B-CELLS(WS-BASE:8192) NOT = LOW-VALUES
             MOVE 1 TO L-FULL-S(WS-S)
             MOVE WS-S TO L-TOP
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-STOPGAP-SECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-COLUMN.
*> USING CLIENT-STATE, row (not 0), full and top (SKY-STOPGAP-SECTIONS), column (1 to 256: z * 16 + x + 1), surface out,
*> fluid top out (BINARY-LONG; see WR-SURF and WR-WTOP): scans the column down from the highest section that has any block
*> for its topmost opaque block (the surface is one above it) and for the top of the fluid met on the way, if any.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-S                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-YBOTTOM             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-FULL.
    05 L-FULL-S            PIC 9 OCCURS 24 TIMES.
 01 L-TOP                  BINARY-LONG.
 01 L-COLUMN               BINARY-LONG.
 01 L-SURF                 BINARY-LONG.
 01 L-WTOP                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-FULL L-TOP L-COLUMN L-SURF L-WTOP.
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     MOVE 0 TO L-SURF L-WTOP WS-DONE
     PERFORM VARYING WS-S FROM L-TOP BY -1 UNTIL WS-S < 1 OR WS-DONE = 1
         IF L-FULL-S(WS-S) = 1
             COMPUTE WS-Y = WS-S * 16 - 1
             COMPUTE WS-YBOTTOM = WS-S * 16 - 16
             PERFORM UNTIL WS-Y < WS-YBOTTOM OR WS-DONE = 1
                 COMPUTE WS-K = WS-Y * 256 + L-COLUMN
                 MOVE CE-STATE(WS-K) TO WS-STATE
                 EVALUATE TRUE
                     WHEN ST-OPAQUE(WS-STATE + 1) = 1
                         COMPUTE L-SURF = WS-Y + 1
                         MOVE 1 TO WS-DONE
                     WHEN ST-FLUID(WS-STATE + 1) > 0 AND L-WTOP = 0
                         COMPUTE L-WTOP = WS-Y + 1
                 END-EVALUATE
                 SUBTRACT 1 FROM WS-Y
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-STOPGAP-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-SURFACE.
*> USING CLIENT-STATE, row (not 0): WR-SURF and WR-WTOP of the row, unless they are current (WR-SURF-OK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL.
    05 WS-FULL-S           PIC 9 OCCURS 24 TIMES.
 01 WS-TOP                 BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-WTOP                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF WR-SURF-OK(L-ROW) = 1
         GOBACK
     END-IF
     CALL "SKY-STOPGAP-SECTIONS" USING CLIENT-STATE L-ROW WS-FULL WS-TOP
     PERFORM VARYING WS-COLUMN FROM 1 BY 1 UNTIL WS-COLUMN > 256
         CALL "SKY-STOPGAP-COLUMN" USING CLIENT-STATE L-ROW WS-FULL WS-TOP WS-COLUMN WS-SURF WS-WTOP
         MOVE WS-SURF TO WR-SURF(L-ROW, WS-COLUMN)
         MOVE WS-WTOP TO WR-WTOP(L-ROW, WS-COLUMN)
     END-PERFORM
     MOVE 1 TO WR-SURF-OK(L-ROW)
     GOBACK.
 END PROGRAM SKY-STOPGAP-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SKY-STOPGAP-RESURFACE.
*> USING CLIENT-STATE, row (not 0), x, z (local 0 to 15) of a block that changed: when the row's surfaces are current
*> (else the whole row is to be meshed anyway) the column is scanned again; when its surface or fluid top moved, every
*> section between the old and new levels (where the assumed light changed) is to be meshed, in the row and, for a
*> column on the edge of the chunk, in the loaded row beside it (its faces look into this column).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL.
    05 WS-FULL-S           PIC 9 OCCURS 24 TIMES.
 01 WS-TOP                 BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-WTOP                BINARY-LONG.
 01 WS-OLD-SURF            BINARY-LONG.
 01 WS-OLD-WTOP            BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Z.
     IF WR-SURF-OK(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-COLUMN = L-Z * 16 + L-X + 1
     MOVE WR-SURF(L-ROW, WS-COLUMN) TO WS-OLD-SURF
     MOVE WR-WTOP(L-ROW, WS-COLUMN) TO WS-OLD-WTOP
     CALL "SKY-STOPGAP-SECTIONS" USING CLIENT-STATE L-ROW WS-FULL WS-TOP
     CALL "SKY-STOPGAP-COLUMN" USING CLIENT-STATE L-ROW WS-FULL WS-TOP WS-COLUMN WS-SURF WS-WTOP
     MOVE WS-SURF TO WR-SURF(L-ROW, WS-COLUMN)
     MOVE WS-WTOP TO WR-WTOP(L-ROW, WS-COLUMN)
     IF WS-SURF = WS-OLD-SURF AND WS-WTOP = WS-OLD-WTOP
         GOBACK
     END-IF
*>   A surface of 0 is a column with no opaque block at all (never in a real world: there is bedrock): nothing below it to
*>   darken, the block's own sections are meshed by the block set.
     IF WS-SURF = 0 OR WS-OLD-SURF = 0
         GOBACK
     END-IF
*>   Cells below both surfaces are dark before and after; the fluid above a surface changes no lower cell.
     MOVE WS-SURF TO WS-LO
     IF WS-OLD-SURF < WS-LO
         MOVE WS-OLD-SURF TO WS-LO
     END-IF
     MOVE WS-SURF TO WS-HI
     IF WS-OLD-SURF > WS-HI
         MOVE WS-OLD-SURF TO WS-HI
     END-IF
     IF WS-WTOP > WS-HI
         MOVE WS-WTOP TO WS-HI
     END-IF
     IF WS-OLD-WTOP > WS-HI
         MOVE WS-OLD-WTOP TO WS-HI
     END-IF
     COMPUTE WS-S1 = WS-LO / 16 + 1
     COMPUTE WS-S2 = WS-HI / 16 + 1
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     IF WS-S2 > WS-SECTIONS
         MOVE WS-SECTIONS TO WS-S2
     END-IF
     PERFORM VARYING WS-S FROM WS-S1 BY 1 UNTIL WS-S > WS-S2
*>       A section with no block has no mesh to light again.
         IF WS-FULL-S(WS-S) = 1
             MOVE 1 TO WR-DIRTY(L-ROW, WS-S)
         END-IF
         MOVE WR-CX(L-ROW) TO WS-NX
         MOVE WR-CZ(L-ROW) TO WS-NZ
         IF L-X = 0
             COMPUTE WS-CX = WR-CX(L-ROW) - 1
             CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-CX WS-NZ WS-S
         END-IF
         IF L-X = 15
             COMPUTE WS-CX = WR-CX(L-ROW) + 1
             CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-CX WS-NZ WS-S
         END-IF
         IF L-Z = 0
             COMPUTE WS-CZ = WR-CZ(L-ROW) - 1
             CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-NX WS-CZ WS-S
         END-IF
         IF L-Z = 15
             COMPUTE WS-CZ = WR-CZ(L-ROW) + 1
             CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-NX WS-CZ WS-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SKY-STOPGAP-RESURFACE.

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
