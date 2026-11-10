*> Section meshing (research R4; data-model §13 per-face brightness; standin-content §1.1): MESH-SECTION
*> turns the cells of one 16-high section of a replica row into two vertex lists (28-byte vertices,
*> shim-abi §9; positions relative to the section's lowest corner): every baked quad of every block
*> (BM-STATE) whose cull direction is not hidden by its neighbour. A neighbour hides a face when it
*> is opaque, or when it is the same non-opaque block (lucite against lucite). The face's
*> brightness is its direction's factor (up 1.0, north and south 0.8, east and west 0.6, down 0.5)
*> times max(sky light x daylight, block light) / 15 of the cell it looks into, at least 0.1.
*> Faces whose sprite has partial alpha go to the translucent list. MESH-DIRTY meshes up to a
*> budget of sections marked dirty.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-DIRTY.
*> USING CLIENT-STATE, budget (sections at most).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BUDGET               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BUDGET.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT OR WS-DONE >= L-BUDGET
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS OR WS-DONE >= L-BUDGET
             IF WR-USED(WS-R) = 1 AND WR-DIRTY(WS-R, WS-S) = 1
                 CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                 ADD 1 TO WS-DONE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MESH-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-SECTION.
*> USING CLIENT-STATE, row, section (1-based): replaces the section's meshes, marks them for upload.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
 01 WS-NEIGHBOURS.
    05 WS-NROW             BINARY-LONG OCCURS 4 TIMES.   *> west, east, north, south rows (0 none)
 01 WS-OPAQUE.
    05 WS-OV OCCURS 147456 TIMES.
       10 WS-OV-X          FLOAT-SHORT.
       10 WS-OV-Y          FLOAT-SHORT.
       10 WS-OV-Z          FLOAT-SHORT.
       10 WS-OV-U          FLOAT-SHORT.
       10 WS-OV-V          FLOAT-SHORT.
       10 WS-OV-B          FLOAT-SHORT.
       10 WS-OV-A          FLOAT-SHORT.
 01 WS-TRANSLUCENT.
    05 WS-TV OCCURS 147456 TIMES.
       10 WS-TV-X          FLOAT-SHORT.
       10 WS-TV-Y          FLOAT-SHORT.
       10 WS-TV-Z          FLOAT-SHORT.
       10 WS-TV-U          FLOAT-SHORT.
       10 WS-TV-V          FLOAT-SHORT.
       10 WS-TV-B          FLOAT-SHORT.
       10 WS-TV-A          FLOAT-SHORT.
 01 WS-OCOUNT              BINARY-LONG.
 01 WS-TCOUNT              BINARY-LONG.
 01 WS-DIRS.
    05 FILLER PIC X(3) VALUE "101".
    05 FILLER PIC X(3) VALUE "121".
    05 FILLER PIC X(3) VALUE "110".
    05 FILLER PIC X(3) VALUE "112".
    05 FILLER PIC X(3) VALUE "011".
    05 FILLER PIC X(3) VALUE "211".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR OCCURS 6 TIMES.
       10 WS-DX            PIC 9.
       10 WS-DY            PIC 9.
       10 WS-DZ            PIC 9.
 01 WS-FACTORS.
    05 FILLER PIC 9V9 VALUE 0.5.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTORS.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-BASE                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW-STATE           BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-NSKY                BINARY-LONG.
 01 WS-NBLOCK              BINARY-LONG.
 01 WS-CULL                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-LIGHT               FLOAT-SHORT.
 01 WS-BRIGHT              FLOAT-SHORT.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CORNER           BINARY-LONG OCCURS 6 TIMES.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 B-MESH                 PIC X(4128768) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-S.
     MOVE 1 TO WS-CORNER(1) WS-CORNER(4)
     MOVE 2 TO WS-CORNER(2)
     MOVE 3 TO WS-CORNER(3) WS-CORNER(5)
     MOVE 4 TO WS-CORNER(6)
     MOVE 0 TO WS-OCOUNT WS-TCOUNT
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE PL-HEIGHT TO WS-HEIGHT
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     COMPUTE WS-CX = WR-CX(L-ROW) - 1
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WR-CZ(L-ROW) WS-NROW(1)
     COMPUTE WS-CX = WR-CX(L-ROW) + 1
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WR-CZ(L-ROW) WS-NROW(2)
     COMPUTE WS-CZ = WR-CZ(L-ROW) - 1
     CALL "WORLD-ROW" USING CLIENT-STATE WR-CX(L-ROW) WS-CZ WS-NROW(3)
     COMPUTE WS-CZ = WR-CZ(L-ROW) + 1
     CALL "WORLD-ROW" USING CLIENT-STATE WR-CX(L-ROW) WS-CZ WS-NROW(4)
     COMPUTE WS-BASE = (L-S - 1) * 4096
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 4096
         MOVE CE-STATE(WS-BASE + WS-CELL) TO WS-STATE
         IF WS-STATE > 0 AND WS-STATE < CL-MAX-BAKED
             COMPUTE WS-LY = (WS-CELL - 1) / 256
             COMPUTE WS-Z = FUNCTION MOD((WS-CELL - 1) / 16, 16)
             COMPUTE WS-X = FUNCTION MOD(WS-CELL - 1, 16)
             COMPUTE WS-Y = (L-S - 1) * 16 + WS-LY
             COMPUTE WS-ROW-STATE = WS-STATE + 1
             PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-ROW-STATE)
*>               The cull neighbour.
                 MOVE BM-CULL(WS-ROW-STATE, WS-Q) TO WS-D
                 MOVE 0 TO WS-CULL
                 IF WS-D > 0
                     CALL "MESH-CELL" USING CLIENT-STATE L-ROW WS-NEIGHBOURS WS-HEIGHT WS-X WS-Y
                         WS-Z WS-D WS-NSTATE WS-NSKY WS-NBLOCK
                     IF ST-OPAQUE(WS-NSTATE + 1) = 1
                         MOVE 1 TO WS-CULL
                     END-IF
                     IF ST-BLOCK(WS-NSTATE + 1) = ST-BLOCK(WS-ROW-STATE)
                             AND ST-OPAQUE(WS-ROW-STATE) = 0
                         MOVE 1 TO WS-CULL
                     END-IF
                 END-IF
                 IF WS-CULL = 0
*>                   The light of the cell the face looks into.
                     MOVE BM-SHADE(WS-ROW-STATE, WS-Q) TO WS-D
                     CALL "MESH-CELL" USING CLIENT-STATE L-ROW WS-NEIGHBOURS WS-HEIGHT WS-X WS-Y
                         WS-Z WS-D WS-NSTATE WS-NSKY WS-NBLOCK
                     COMPUTE WS-LIGHT = FUNCTION MAX(WS-NSKY * SK-U / 1000, WS-NBLOCK)
                     COMPUTE WS-BRIGHT = FUNCTION MAX(WS-FACTOR(WS-D) * WS-LIGHT / 15, 0.1)
                     MOVE BM-SPRITE(WS-ROW-STATE, WS-Q) TO WS-SPRITE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE WS-CORNER(WS-K) TO WS-C
                         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE BM-U(WS-ROW-STATE, WS-Q, WS-C)
                             BM-V(WS-ROW-STATE, WS-Q, WS-C) WS-U WS-V
                         IF AT-TRANSLUCENT(WS-SPRITE) = 1
                             ADD 1 TO WS-TCOUNT
                             COMPUTE WS-TV-X(WS-TCOUNT) = WS-X + BM-X(WS-ROW-STATE, WS-Q, WS-C)
                             COMPUTE WS-TV-Y(WS-TCOUNT) = WS-LY + BM-Y(WS-ROW-STATE, WS-Q, WS-C)
                             COMPUTE WS-TV-Z(WS-TCOUNT) = WS-Z + BM-Z(WS-ROW-STATE, WS-Q, WS-C)
                             MOVE WS-U TO WS-TV-U(WS-TCOUNT)
                             MOVE WS-V TO WS-TV-V(WS-TCOUNT)
                             MOVE WS-BRIGHT TO WS-TV-B(WS-TCOUNT)
                             MOVE 1 TO WS-TV-A(WS-TCOUNT)
                         ELSE
                             ADD 1 TO WS-OCOUNT
                             COMPUTE WS-OV-X(WS-OCOUNT) = WS-X + BM-X(WS-ROW-STATE, WS-Q, WS-C)
                             COMPUTE WS-OV-Y(WS-OCOUNT) = WS-LY + BM-Y(WS-ROW-STATE, WS-Q, WS-C)
                             COMPUTE WS-OV-Z(WS-OCOUNT) = WS-Z + BM-Z(WS-ROW-STATE, WS-Q, WS-C)
                             MOVE WS-U TO WS-OV-U(WS-OCOUNT)
                             MOVE WS-V TO WS-OV-V(WS-OCOUNT)
                             MOVE WS-BRIGHT TO WS-OV-B(WS-OCOUNT)
                             MOVE 1 TO WS-OV-A(WS-OCOUNT)
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   The new meshes replace the old ones.
     IF WR-OP-ADDR(L-ROW, L-S) NOT = NULL
         FREE WR-OP-ADDR(L-ROW, L-S)
     END-IF
     IF WR-TR-ADDR(L-ROW, L-S) NOT = NULL
         FREE WR-TR-ADDR(L-ROW, L-S)
     END-IF
     MOVE WS-OCOUNT TO WR-OP-COUNT(L-ROW, L-S)
     MOVE WS-TCOUNT TO WR-TR-COUNT(L-ROW, L-S)
     COMPUTE WS-BYTES = FUNCTION MAX(WS-OCOUNT, 1) * 28
     ALLOCATE WS-BYTES CHARACTERS RETURNING WR-OP-ADDR(L-ROW, L-S)
     SET ADDRESS OF B-MESH TO WR-OP-ADDR(L-ROW, L-S)
     MOVE WS-OPAQUE(1:WS-BYTES) TO B-MESH(1:WS-BYTES)
     COMPUTE WS-BYTES = FUNCTION MAX(WS-TCOUNT, 1) * 28
     ALLOCATE WS-BYTES CHARACTERS RETURNING WR-TR-ADDR(L-ROW, L-S)
     SET ADDRESS OF B-MESH TO WR-TR-ADDR(L-ROW, L-S)
     MOVE WS-TRANSLUCENT(1:WS-BYTES) TO B-MESH(1:WS-BYTES)
     MOVE 0 TO WR-DIRTY(L-ROW, L-S)
     MOVE 1 TO WR-UPLOAD(L-ROW, L-S)
     GOBACK.

 END PROGRAM MESH-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-CELL.
*> USING CLIENT-STATE, row, neighbour rows (west, east, north, south; 0 = not loaded), height,
*> x, y, z (in the row), direction (DIR-*), state out, sky light out, block light out: the
*> neighbour cell in that direction. Beside the row it is read from the neighbouring row (none
*> loaded: void under full sky light); above the world void under full sky light, below it void and
*> dark.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-DIRS.
    05 FILLER PIC X(3) VALUE "101".
    05 FILLER PIC X(3) VALUE "121".
    05 FILLER PIC X(3) VALUE "110".
    05 FILLER PIC X(3) VALUE "112".
    05 FILLER PIC X(3) VALUE "011".
    05 FILLER PIC X(3) VALUE "211".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR OCCURS 6 TIMES.
       10 WS-DX            PIC 9.
       10 WS-DY            PIC 9.
       10 WS-DZ            PIC 9.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KIND-SKY            BINARY-LONG VALUE 0.
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NEIGHBOURS.
    05 L-NROW              BINARY-LONG OCCURS 4 TIMES.
 01 L-HEIGHT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NEIGHBOURS L-HEIGHT L-X L-Y L-Z L-D L-STATE
         L-SKY L-BLOCK.
     COMPUTE WS-NX = L-X + WS-DX(L-D) - 1
     COMPUTE WS-NY = L-Y + WS-DY(L-D) - 1
     COMPUTE WS-NZ = L-Z + WS-DZ(L-D) - 1
     MOVE 0 TO L-STATE L-BLOCK
     MOVE 15 TO L-SKY
     MOVE L-ROW TO WS-ROW
     EVALUATE TRUE
         WHEN WS-NX < 0
             MOVE L-NROW(1) TO WS-ROW
             ADD 16 TO WS-NX
         WHEN WS-NX > 15
             MOVE L-NROW(2) TO WS-ROW
             SUBTRACT 16 FROM WS-NX
         WHEN WS-NZ < 0
             MOVE L-NROW(3) TO WS-ROW
             ADD 16 TO WS-NZ
         WHEN WS-NZ > 15
             MOVE L-NROW(4) TO WS-ROW
             SUBTRACT 16 FROM WS-NZ
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-NY < 0
             MOVE 0 TO L-SKY
         WHEN WS-NY >= L-HEIGHT OR WS-ROW = 0
             CONTINUE
         WHEN OTHER
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
             COMPUTE WS-K = WS-NY * 256 + WS-NZ * 16 + WS-NX + 1
             MOVE CE-STATE(WS-K) TO L-STATE
             CALL "LIGHT-GET" USING WR-ADDR(WS-ROW) WS-KIND-SKY WS-NY WS-NX WS-NZ L-SKY
             CALL "LIGHT-GET" USING WR-ADDR(WS-ROW) WS-KIND-BLOCK WS-NY WS-NX WS-NZ L-BLOCK
     END-EVALUATE
     GOBACK.
 END PROGRAM MESH-CELL.
