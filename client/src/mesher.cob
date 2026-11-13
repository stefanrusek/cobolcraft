*> Section meshing (research R4; data-model §13 per-face brightness; standin-content §1.1): MESH-SECTION
*> turns the cells of one 16-high section of a replica row into two vertex lists (44-byte vertices,
*> shim-abi §9: x y z u v brightness alpha sky r g b; positions relative to the section's lowest
*> corner): every baked quad of every block (BM-STATE) whose cull direction is not hidden by its
*> neighbour. A neighbour hides a face when it is opaque, or when it is the same non-opaque block
*> (lucite against lucite). The face's light is its direction's factor (up 1.0, north and south 0.8,
*> east and west 0.6, down 0.5) times the light of the cell it looks into: the vertex's brightness is
*> factor x block light / 15, at least 0.1, and its sky term factor x sky light / 15; the shader draws
*> max(brightness, sky x daylight), so a change of daylight needs no new mesh. The vertex tint is white,
*> except for a face with a tintindex whose block has a tint source (43 section 2: TINT-BLOCK-COLOR with
*> the block's name, ST-BLOCK-NAME, at the cell's position in the world; the biome blend of 43 section
*> 4): its colour as RGB multipliers. Faces whose sprite has partial alpha go to the translucent list.
*> MESH-DIRTY meshes the dirty sections nearest the player first, until the frame's time budget
*> (MB-BUDGET-US) is spent or the section count it is given is reached, and at least one.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-CLOCK.
*> USING CLIENT-STATE, microseconds out (BINARY-DOUBLE): the clock of the frame budget: the injected
*> MB-FAKE-NOW when MB-FAKE is 1 (tests), else the process CPU time (C clock(); the client is one
*> thread, so it is the time spent; CLOCKS_PER_SEC is 1000000).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-US.
     IF MB-FAKE = 1
         MOVE MB-FAKE-NOW TO L-US
     ELSE
         CALL STATIC "clock" RETURNING L-US
     END-IF
     GOBACK.
 END PROGRAM MESH-CLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-DIRTY.
*> USING CLIENT-STATE, budget (sections at most): see the header. MB-MESHED is the number meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-PS                  BINARY-LONG.
 01 WS-ROWKEY              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DS                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CAND.
    05 WS-C-KEY            BINARY-LONG OCCURS 64 TIMES.
    05 WS-C-ROW            BINARY-LONG OCCURS 64 TIMES.
    05 WS-C-SEC            BINARY-LONG OCCURS 64 TIMES.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BUDGET               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BUDGET.
     MOVE 0 TO MB-MESHED
*>   With the credit on (the running client), a frame whose meshing ran long (one section of a dense chunk can take 100 ms) is paid back by
*>   frames that mesh nothing: the average is CL-MESH-CREDIT-US a frame, and the frame rate holds while the world loads.
     IF MB-CREDIT-ON = 1
         ADD CL-MESH-CREDIT-US TO MB-CREDIT
         IF MB-CREDIT > CL-MESH-CREDIT-US
             MOVE CL-MESH-CREDIT-US TO MB-CREDIT
         END-IF
         IF MB-CREDIT < 0
             MOVE 0 TO MB-LAST-US
             GOBACK
         END-IF
     END-IF
     CALL "MESH-CLOCK" USING CLIENT-STATE WS-T0
     MOVE FUNCTION MIN(L-BUDGET, 64) TO WS-K
     COMPUTE WS-PCX = FUNCTION INTEGER(PL-X / 16)
     COMPUTE WS-PCZ = FUNCTION INTEGER(PL-Z / 16)
     COMPUTE WS-PS = FUNCTION INTEGER((PL-Y - PL-MIN-Y) / 16) + 1
     MOVE 0 TO WS-N
*>   The WS-K dirty sections nearest the player (in units of 16 blocks), nearest first.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             COMPUTE WS-ROWKEY = (WR-CX(WS-R) - WS-PCX) * (WR-CX(WS-R) - WS-PCX)
                 + (WR-CZ(WS-R) - WS-PCZ) * (WR-CZ(WS-R) - WS-PCZ)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 IF WR-DIRTY(WS-R, WS-S) = 1
                     COMPUTE WS-DS = WS-S - WS-PS
                     COMPUTE WS-KEY = WS-ROWKEY + WS-DS * WS-DS
                     IF WS-N < WS-K
                         ADD 1 TO WS-N
                         MOVE WS-N TO WS-I
                         MOVE 1 TO WS-J
                     ELSE
                         MOVE 0 TO WS-J
                         IF WS-KEY < WS-C-KEY(WS-N)
                             MOVE WS-N TO WS-I
                             MOVE 1 TO WS-J
                         END-IF
                     END-IF
                     IF WS-J = 1
                         PERFORM UNTIL WS-I = 1
                             COMPUTE WS-J = WS-I - 1
                             IF WS-C-KEY(WS-J) <= WS-KEY
                                 EXIT PERFORM
                             END-IF
                             MOVE WS-C-KEY(WS-J) TO WS-C-KEY(WS-I)
                             MOVE WS-C-ROW(WS-J) TO WS-C-ROW(WS-I)
                             MOVE WS-C-SEC(WS-J) TO WS-C-SEC(WS-I)
                             MOVE WS-J TO WS-I
                         END-PERFORM
                         MOVE WS-KEY TO WS-C-KEY(WS-I)
                         MOVE WS-R TO WS-C-ROW(WS-I)
                         MOVE WS-S TO WS-C-SEC(WS-I)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-I > 1
             CALL "MESH-CLOCK" USING CLIENT-STATE WS-T1
             IF WS-T1 - WS-T0 >= MB-BUDGET-US
                 EXIT PERFORM
             END-IF
         END-IF
         CALL "MESH-SECTION" USING CLIENT-STATE WS-C-ROW(WS-I) WS-C-SEC(WS-I)
         ADD 1 TO MB-MESHED
         IF MB-FAKE = 1
             ADD MB-FAKE-STEP TO MB-FAKE-NOW
         END-IF
     END-PERFORM
     CALL "MESH-CLOCK" USING CLIENT-STATE WS-T1
     COMPUTE MB-LAST-US = WS-T1 - WS-T0
     IF MB-CREDIT-ON = 1
         SUBTRACT MB-LAST-US FROM MB-CREDIT
     END-IF
     GOBACK.
 END PROGRAM MESH-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-SECTION.
*> USING CLIENT-STATE, row, section (1-based): replaces the section's meshes, marks them for upload. A
*> section of only air has no vertices and is done at once (MB-EMPTY counts it). A cell that is opaque with
*> six opaque neighbours (MESH-HIDDEN) has no visible face and is not looked at further.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
 COPY CLTINTQ.
 COPY CLFLUID.
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
       10 WS-OV-S          FLOAT-SHORT.
       10 WS-OV-R          FLOAT-SHORT.
       10 WS-OV-G          FLOAT-SHORT.
       10 WS-OV-BL         FLOAT-SHORT.
 01 WS-TRANSLUCENT.
    05 WS-TV OCCURS 147456 TIMES.
       10 WS-TV-X          FLOAT-SHORT.
       10 WS-TV-Y          FLOAT-SHORT.
       10 WS-TV-Z          FLOAT-SHORT.
       10 WS-TV-U          FLOAT-SHORT.
       10 WS-TV-V          FLOAT-SHORT.
       10 WS-TV-B          FLOAT-SHORT.
       10 WS-TV-A          FLOAT-SHORT.
       10 WS-TV-S          FLOAT-SHORT.
       10 WS-TV-R          FLOAT-SHORT.
       10 WS-TV-G          FLOAT-SHORT.
       10 WS-TV-BL         FLOAT-SHORT.
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
 01 WS-LAST                BINARY-LONG.
 01 WS-SEC-Y               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW-STATE           BINARY-LONG.
 01 WS-BM                  BINARY-LONG.
 01 WS-NO-STATE            BINARY-LONG VALUE 0.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-CULL-D              BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-NSKY                BINARY-LONG.
 01 WS-NBLOCK              BINARY-LONG.
 01 WS-CULL                BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-BRIGHT              FLOAT-SHORT.
 01 WS-SKYTERM             FLOAT-SHORT.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CORNER           BINARY-LONG OCCURS 6 TIMES.
 01 WS-QUV.
    05 WS-QUV-C OCCURS 4 TIMES.
       10 WS-QU            FLOAT-SHORT.
       10 WS-QV            FLOAT-SHORT.
       10 WS-QX            FLOAT-SHORT.
       10 WS-QY            FLOAT-SHORT.
       10 WS-QZ            FLOAT-SHORT.
 01 WS-KP                  BINARY-LONG.
 01 WS-FONE                FLOAT-SHORT VALUE 1.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-POSITIONS.
    05 WS-POS              FLOAT-SHORT OCCURS 273 TIMES.   *> k / 16, k = 0 to 272 (index k + 1)
 01 WS-LIGHTS.
    05 WS-LIGHT-DIR OCCURS 6 TIMES.
       10 WS-LB            FLOAT-SHORT OCCURS 16 TIMES.     *> max(factor x block light / 15, 0.1)
       10 WS-LS            FLOAT-SHORT OCCURS 16 TIMES.     *> factor x sky light / 15
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-TINT-INDEX          BINARY-LONG.
 01 WS-TINT-CACHE.
    05 WS-TC OCCURS 3 TIMES.
       10 WS-TC-DONE       BINARY-LONG.
       10 WS-TC-R          FLOAT-SHORT.
       10 WS-TC-G          FLOAT-SHORT.
       10 WS-TC-B          FLOAT-SHORT.
 01 WS-TR                  FLOAT-SHORT.
 01 WS-TG                  FLOAT-SHORT.
 01 WS-TB                  FLOAT-SHORT.
 01 WS-CH                  BINARY-DOUBLE.
 01 B-MESH                 PIC X(6488064) BASED.
 01 B-CELLS                PIC X(196608) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-S.
*>   The tables of sixteenths and of light (built once: float arithmetic is the cost of meshing).
     IF WS-READY = 0
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 272
             COMPUTE WS-POS(WS-K + 1) = WS-K / 16
         END-PERFORM
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 15
                 COMPUTE WS-LB(WS-D, WS-C + 1) = FUNCTION MAX(WS-FACTOR(WS-D) * WS-C / 15, 0.1)
                 COMPUTE WS-LS(WS-D, WS-C + 1) = WS-FACTOR(WS-D) * WS-C / 15
             END-PERFORM
         END-PERFORM
         MOVE 1 TO WS-READY
     END-IF
     MOVE 1 TO WS-CORNER(1) WS-CORNER(4)
     MOVE 2 TO WS-CORNER(2)
     MOVE 3 TO WS-CORNER(3) WS-CORNER(5)
     MOVE 4 TO WS-CORNER(6)
     MOVE 0 TO WS-OCOUNT WS-TCOUNT
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-NO-STATE WS-BM
     MOVE PL-HEIGHT TO WS-HEIGHT
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
     COMPUTE WS-BASE = (L-S - 1) * 4096
     MOVE 15 TO WS-LAST
     COMPUTE WS-SEC-Y = (L-S - 1) * 16
*>   A section of only air: no vertices, none of the neighbour work.
     SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
     IF B-CELLS(WS-BASE * 2 + 1:8192) = LOW-VALUES
         MOVE -1 TO WS-LAST
         ADD 1 TO MB-EMPTY
     ELSE
         COMPUTE WS-CX = WR-CX(L-ROW) - 1
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WR-CZ(L-ROW) WS-NROW(1)
         COMPUTE WS-CX = WR-CX(L-ROW) + 1
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WR-CZ(L-ROW) WS-NROW(2)
         COMPUTE WS-CZ = WR-CZ(L-ROW) - 1
         CALL "WORLD-ROW" USING CLIENT-STATE WR-CX(L-ROW) WS-CZ WS-NROW(3)
         COMPUTE WS-CZ = WR-CZ(L-ROW) + 1
         CALL "WORLD-ROW" USING CLIENT-STATE WR-CX(L-ROW) WS-CZ WS-NROW(4)
     END-IF
     MOVE 0 TO WS-CELL
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > WS-LAST
      PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > WS-LAST
       PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > WS-LAST
         ADD 1 TO WS-CELL
         MOVE CE-STATE(WS-BASE + WS-CELL) TO WS-STATE
*>       The row of the state's baked quads: its own in the stand-in table, the one taken for it on first
*>       use in a standard world (MODEL-SLOT-OF); 0 when there is none (the cell draws nothing).
         MOVE 0 TO WS-BM
         IF WS-STATE > 0
             IF BM-MODE = 1 AND WS-STATE < CL-MAX-BAKED
                 COMPUTE WS-BM = WS-STATE + 1
             END-IF
             IF BM-MODE = 2 AND WS-STATE < CL-MAX-STATES
                 MOVE BM-SLOT(WS-STATE + 1) TO WS-BM
                 IF WS-BM = 0
                     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-BM
                 END-IF
             END-IF
         END-IF
*>       A cell of water or lava draws the fluid mesh (MESH-FLUID, 29a section 10); a liquid block has no baked model.
         IF WS-STATE > 0
             IF ST-FLUID(WS-STATE + 1) > 0
                 COMPUTE WS-Y = WS-SEC-Y + WS-LY
                 CALL "MESH-FLUID" USING CLIENT-STATE L-ROW WS-X WS-Y WS-Z WS-LY WS-HEIGHT WS-STATE FLUID-OUT
                 PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > FO-COUNT
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE WS-CORNER(WS-K) TO WS-C
                         IF FO-TRANSLUCENT(WS-Q) = 1
                             ADD 1 TO WS-TCOUNT
                             MOVE FO-X(WS-Q, WS-C) TO WS-TV-X(WS-TCOUNT)
                             MOVE FO-Y(WS-Q, WS-C) TO WS-TV-Y(WS-TCOUNT)
                             MOVE FO-Z(WS-Q, WS-C) TO WS-TV-Z(WS-TCOUNT)
                             MOVE FO-U(WS-Q, WS-C) TO WS-TV-U(WS-TCOUNT)
                             MOVE FO-V(WS-Q, WS-C) TO WS-TV-V(WS-TCOUNT)
                             MOVE FO-BRIGHT(WS-Q) TO WS-TV-B(WS-TCOUNT)
                             MOVE WS-FONE TO WS-TV-A(WS-TCOUNT)
                             MOVE FO-SKY(WS-Q) TO WS-TV-S(WS-TCOUNT)
                             MOVE FO-R(WS-Q) TO WS-TV-R(WS-TCOUNT)
                             MOVE FO-G(WS-Q) TO WS-TV-G(WS-TCOUNT)
                             MOVE FO-B(WS-Q) TO WS-TV-BL(WS-TCOUNT)
                         ELSE
                             ADD 1 TO WS-OCOUNT
                             MOVE FO-X(WS-Q, WS-C) TO WS-OV-X(WS-OCOUNT)
                             MOVE FO-Y(WS-Q, WS-C) TO WS-OV-Y(WS-OCOUNT)
                             MOVE FO-Z(WS-Q, WS-C) TO WS-OV-Z(WS-OCOUNT)
                             MOVE FO-U(WS-Q, WS-C) TO WS-OV-U(WS-OCOUNT)
                             MOVE FO-V(WS-Q, WS-C) TO WS-OV-V(WS-OCOUNT)
                             MOVE FO-BRIGHT(WS-Q) TO WS-OV-B(WS-OCOUNT)
                             MOVE WS-FONE TO WS-OV-A(WS-OCOUNT)
                             MOVE FO-SKY(WS-Q) TO WS-OV-S(WS-OCOUNT)
                             MOVE FO-R(WS-Q) TO WS-OV-R(WS-OCOUNT)
                             MOVE FO-G(WS-Q) TO WS-OV-G(WS-OCOUNT)
                             MOVE FO-B(WS-Q) TO WS-OV-BL(WS-OCOUNT)
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 IF ST-FLUID(WS-STATE + 1) < 3
                     MOVE 0 TO WS-BM
                 END-IF
             END-IF
         END-IF
         IF WS-BM > 0
             COMPUTE WS-Y = WS-SEC-Y + WS-LY
             COMPUTE WS-ROW-STATE = WS-STATE + 1
             MOVE 0 TO WS-HIDDEN
             IF ST-OPAQUE(WS-ROW-STATE) = 1
                 CALL "MESH-HIDDEN" USING CLIENT-STATE L-ROW WS-NEIGHBOURS WS-HEIGHT WS-X WS-Y WS-Z
                     WS-HIDDEN
             END-IF
             IF WS-HIDDEN = 0
                 MOVE 0 TO WS-TC-DONE(1) WS-TC-DONE(2) WS-TC-DONE(3)
                 PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-BM)
*>                   The cull neighbour.
                     MOVE BM-CULL(WS-BM, WS-Q) TO WS-CULL-D
                     MOVE 0 TO WS-CULL
                     IF WS-CULL-D > 0
                         CALL "MESH-CELL" USING CLIENT-STATE L-ROW WS-NEIGHBOURS WS-HEIGHT WS-X
                             WS-Y WS-Z WS-CULL-D WS-NSTATE WS-NSKY WS-NBLOCK
                         IF ST-OPAQUE(WS-NSTATE + 1) = 1
                             MOVE 1 TO WS-CULL
                         END-IF
                         IF ST-BLOCK(WS-NSTATE + 1) = ST-BLOCK(WS-ROW-STATE)
                                 AND ST-OPAQUE(WS-ROW-STATE) = 0
                             MOVE 1 TO WS-CULL
                         END-IF
                     END-IF
                     IF WS-CULL = 0
*>                       The light of the cell the face looks into (the cull neighbour when it is that cell).
                         MOVE BM-SHADE(WS-BM, WS-Q) TO WS-D
                         IF WS-D NOT = WS-CULL-D
                             CALL "MESH-CELL" USING CLIENT-STATE L-ROW WS-NEIGHBOURS WS-HEIGHT WS-X
                                 WS-Y WS-Z WS-D WS-NSTATE WS-NSKY WS-NBLOCK
                         END-IF
                         MOVE WS-LB(WS-D, WS-NBLOCK + 1) TO WS-BRIGHT
                         MOVE WS-LS(WS-D, WS-NSKY + 1) TO WS-SKYTERM
                         MOVE BM-SPRITE(WS-BM, WS-Q) TO WS-SPRITE
*>                       The four corners: atlas coordinates baked, positions from the table of sixteenths
*>                       (a corner that is not on a sixteenth is added up).
                         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                             MOVE BM-AU(WS-BM, WS-Q, WS-C) TO WS-QU(WS-C)
                             MOVE BM-AV(WS-BM, WS-Q, WS-C) TO WS-QV(WS-C)
                             IF BM-IX(WS-BM, WS-Q, WS-C) >= 0
                                 COMPUTE WS-KP = WS-X * 16 + BM-IX(WS-BM, WS-Q, WS-C) + 1
                                 MOVE WS-POS(WS-KP) TO WS-QX(WS-C)
                             ELSE
                                 COMPUTE WS-QX(WS-C) = WS-X + BM-X(WS-BM, WS-Q, WS-C)
                             END-IF
                             IF BM-IY(WS-BM, WS-Q, WS-C) >= 0
                                 COMPUTE WS-KP = WS-LY * 16 + BM-IY(WS-BM, WS-Q, WS-C) + 1
                                 MOVE WS-POS(WS-KP) TO WS-QY(WS-C)
                             ELSE
                                 COMPUTE WS-QY(WS-C) = WS-LY + BM-Y(WS-BM, WS-Q, WS-C)
                             END-IF
                             IF BM-IZ(WS-BM, WS-Q, WS-C) >= 0
                                 COMPUTE WS-KP = WS-Z * 16 + BM-IZ(WS-BM, WS-Q, WS-C) + 1
                                 MOVE WS-POS(WS-KP) TO WS-QZ(WS-C)
                             ELSE
                                 COMPUTE WS-QZ(WS-C) = WS-Z + BM-Z(WS-BM, WS-Q, WS-C)
                             END-IF
                         END-PERFORM
*>                       The tint of the face: white without a tintindex or a source.
                         MOVE WS-FONE TO WS-TR WS-TG WS-TB
                         MOVE BM-TINT(WS-BM, WS-Q) TO WS-TINT-INDEX
                         IF WS-TINT-INDEX >= 0 AND WS-TINT-INDEX <= 2
                             IF WS-TC-DONE(WS-TINT-INDEX + 1) = 0
                                 MOVE ST-BLOCK(WS-ROW-STATE) TO WS-BLOCK-ID
                                 MOVE SPACES TO WS-NAME
                                 IF WS-BLOCK-ID >= 0 AND WS-BLOCK-ID < 2048
                                     MOVE ST-BLOCK-NAME(WS-BLOCK-ID + 1) TO WS-NAME
                                 END-IF
*>                               The fluid renderer colours water with the water() source (43 section 2.1).
                                 IF WS-NAME = "water"
                                     MOVE "water_cauldron" TO WS-NAME
                                 END-IF
                                 MOVE WS-NAME TO TQ-NAME
                                 MOVE WS-TINT-INDEX TO TQ-INDEX
                                 MOVE 1 TO TQ-MODE
                                 MOVE 0 TO TQ-HALF TQ-POWER TQ-AGE
                                 COMPUTE TQ-X = WR-CX(L-ROW) * 16 + WS-X
                                 COMPUTE TQ-Y = WS-Y + PL-MIN-Y
                                 COMPUTE TQ-Z = WR-CZ(L-ROW) * 16 + WS-Z
                                 MOVE CL-TINT-RADIUS TO TQ-RADIUS
                                 MOVE 4294967295 TO TQ-COLOUR
                                 IF WS-NAME NOT = SPACES
                                     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
                                 END-IF
                                 MOVE 1 TO WS-TC-R(WS-TINT-INDEX + 1) WS-TC-G(WS-TINT-INDEX + 1)
                                     WS-TC-B(WS-TINT-INDEX + 1)
*>                               A colour with no alpha (a colormap not loaded: all zero, 43 section 3.1)
*>                               is not applied.
                                 IF TQ-COLOUR >= 16777216
                                     COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR / 65536, 256)
                                     COMPUTE WS-TC-R(WS-TINT-INDEX + 1) = WS-CH / 255
                                     COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR / 256, 256)
                                     COMPUTE WS-TC-G(WS-TINT-INDEX + 1) = WS-CH / 255
                                     COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR, 256)
                                     COMPUTE WS-TC-B(WS-TINT-INDEX + 1) = WS-CH / 255
                                 END-IF
                                 MOVE 1 TO WS-TC-DONE(WS-TINT-INDEX + 1)
                             END-IF
                             MOVE WS-TC-R(WS-TINT-INDEX + 1) TO WS-TR
                             MOVE WS-TC-G(WS-TINT-INDEX + 1) TO WS-TG
                             MOVE WS-TC-B(WS-TINT-INDEX + 1) TO WS-TB
                         END-IF
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                             MOVE WS-CORNER(WS-K) TO WS-C
                             IF AT-TRANSLUCENT(WS-SPRITE) = 1
                                 ADD 1 TO WS-TCOUNT
                                 MOVE WS-QX(WS-C) TO WS-TV-X(WS-TCOUNT)
                                 MOVE WS-QY(WS-C) TO WS-TV-Y(WS-TCOUNT)
                                 MOVE WS-QZ(WS-C) TO WS-TV-Z(WS-TCOUNT)
                                 MOVE WS-QU(WS-C) TO WS-TV-U(WS-TCOUNT)
                                 MOVE WS-QV(WS-C) TO WS-TV-V(WS-TCOUNT)
                                 MOVE WS-BRIGHT TO WS-TV-B(WS-TCOUNT)
                                 MOVE WS-FONE TO WS-TV-A(WS-TCOUNT)
                                 MOVE WS-SKYTERM TO WS-TV-S(WS-TCOUNT)
                                 MOVE WS-TR TO WS-TV-R(WS-TCOUNT)
                                 MOVE WS-TG TO WS-TV-G(WS-TCOUNT)
                                 MOVE WS-TB TO WS-TV-BL(WS-TCOUNT)
                             ELSE
                                 ADD 1 TO WS-OCOUNT
                                 MOVE WS-QX(WS-C) TO WS-OV-X(WS-OCOUNT)
                                 MOVE WS-QY(WS-C) TO WS-OV-Y(WS-OCOUNT)
                                 MOVE WS-QZ(WS-C) TO WS-OV-Z(WS-OCOUNT)
                                 MOVE WS-QU(WS-C) TO WS-OV-U(WS-OCOUNT)
                                 MOVE WS-QV(WS-C) TO WS-OV-V(WS-OCOUNT)
                                 MOVE WS-BRIGHT TO WS-OV-B(WS-OCOUNT)
                                 MOVE WS-FONE TO WS-OV-A(WS-OCOUNT)
                                 MOVE WS-SKYTERM TO WS-OV-S(WS-OCOUNT)
                                 MOVE WS-TR TO WS-OV-R(WS-OCOUNT)
                                 MOVE WS-TG TO WS-OV-G(WS-OCOUNT)
                                 MOVE WS-TB TO WS-OV-BL(WS-OCOUNT)
                             END-IF
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
       END-PERFORM
      END-PERFORM
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
     COMPUTE WS-BYTES = FUNCTION MAX(WS-OCOUNT, 1) * 44
     ALLOCATE WS-BYTES CHARACTERS RETURNING WR-OP-ADDR(L-ROW, L-S)
     SET ADDRESS OF B-MESH TO WR-OP-ADDR(L-ROW, L-S)
     MOVE WS-OPAQUE(1:WS-BYTES) TO B-MESH(1:WS-BYTES)
     COMPUTE WS-BYTES = FUNCTION MAX(WS-TCOUNT, 1) * 44
     ALLOCATE WS-BYTES CHARACTERS RETURNING WR-TR-ADDR(L-ROW, L-S)
     SET ADDRESS OF B-MESH TO WR-TR-ADDR(L-ROW, L-S)
     MOVE WS-TRANSLUCENT(1:WS-BYTES) TO B-MESH(1:WS-BYTES)
     MOVE 0 TO WR-DIRTY(L-ROW, L-S)
     MOVE 1 TO WR-UPLOAD(L-ROW, L-S)
     GOBACK.

 END PROGRAM MESH-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-HIDDEN.
*> USING CLIENT-STATE, row, neighbour rows (as MESH-CELL), height, x, y, z (in the row; y from the
*> dimension's bottom), hidden out (1 when the six neighbours of the cell are opaque): a neighbour inside
*> the row is read directly, the others through MESH-CELL.
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
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NEIGHBOURS.
    05 L-NROW              BINARY-LONG OCCURS 4 TIMES.
 01 L-HEIGHT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HIDDEN               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NEIGHBOURS L-HEIGHT L-X L-Y L-Z L-HIDDEN.
     MOVE 1 TO L-HIDDEN
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(L-ROW)
*>   A cell inside the row (not on a side of it, not at the bottom or top): its six neighbours are cells of the row.
     IF L-X >= 1 AND L-X <= 14 AND L-Z >= 1 AND L-Z <= 14 AND L-Y >= 1 AND L-Y < L-HEIGHT - 1
         COMPUTE WS-K = L-Y * 256 + L-Z * 16 + L-X + 1
         IF ST-OPAQUE(CE-STATE(WS-K - 1) + 1) = 0 OR ST-OPAQUE(CE-STATE(WS-K + 1) + 1) = 0
                 OR ST-OPAQUE(CE-STATE(WS-K - 16) + 1) = 0 OR ST-OPAQUE(CE-STATE(WS-K + 16) + 1) = 0
                 OR ST-OPAQUE(CE-STATE(WS-K - 256) + 1) = 0 OR ST-OPAQUE(CE-STATE(WS-K + 256) + 1) = 0
             MOVE 0 TO L-HIDDEN
         END-IF
         GOBACK
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6 OR L-HIDDEN = 0
         COMPUTE WS-NX = L-X + WS-DX(WS-D) - 1
         COMPUTE WS-NY = L-Y + WS-DY(WS-D) - 1
         COMPUTE WS-NZ = L-Z + WS-DZ(WS-D) - 1
         IF WS-NX >= 0 AND WS-NX <= 15 AND WS-NZ >= 0 AND WS-NZ <= 15
                 AND WS-NY >= 0 AND WS-NY < L-HEIGHT
             COMPUTE WS-K = WS-NY * 256 + WS-NZ * 16 + WS-NX + 1
             MOVE CE-STATE(WS-K) TO WS-STATE
         ELSE
             CALL "MESH-CELL" USING CLIENT-STATE L-ROW L-NEIGHBOURS L-HEIGHT L-X L-Y L-Z WS-D
                 WS-STATE WS-SKY WS-BLOCK
         END-IF
         IF ST-OPAQUE(WS-STATE + 1) = 0
             MOVE 0 TO L-HIDDEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MESH-HIDDEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-CELL.
*> USING CLIENT-STATE, row, neighbour rows (west, east, north, south; 0 = not loaded), height,
*> x, y, z (in the row), direction (DIR-*), state out, sky light out, block light out: the
*> neighbour cell in that direction. Beside the row it is read from the neighbouring row (none
*> loaded: void under full sky light); above the world void under full sky light, below it void and
*> dark. The light is read here (the 4-bit cells of LIGHT-GET) without a call: this runs for every
*> visible face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CLCONST.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-NIB                 BINARY-LONG.
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
     MOVE L-X TO WS-NX
     MOVE L-Y TO WS-NY
     MOVE L-Z TO WS-NZ
     EVALUATE L-D
         WHEN DIR-DOWN
             SUBTRACT 1 FROM WS-NY
         WHEN DIR-UP
             ADD 1 TO WS-NY
         WHEN DIR-NORTH
             SUBTRACT 1 FROM WS-NZ
         WHEN DIR-SOUTH
             ADD 1 TO WS-NZ
         WHEN DIR-WEST
             SUBTRACT 1 FROM WS-NX
         WHEN DIR-EAST
             ADD 1 TO WS-NX
     END-EVALUATE
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
             COMPUTE WS-K = WS-NY * 256 + WS-NZ * 16 + WS-NX
             MOVE CE-STATE(WS-K + 1) TO L-STATE
*>           The light byte holds two cells, the even one in the low nibble; the first light section
*>           (CE-LIGHT-BYTES bytes) is the one below the dimension.
             DIVIDE WS-K BY 2 GIVING WS-HALF REMAINDER WS-ODD
             MOVE CE-SKY(CE-LIGHT-BYTES + WS-HALF + 1) TO WS-BYTE
             IF WS-ODD = 0
                 DIVIDE WS-BYTE BY 16 GIVING WS-NIB REMAINDER L-SKY
             ELSE
                 DIVIDE WS-BYTE BY 16 GIVING L-SKY
             END-IF
             MOVE CE-BLOCK-LIGHT(CE-LIGHT-BYTES + WS-HALF + 1) TO WS-BYTE
             IF WS-ODD = 0
                 DIVIDE WS-BYTE BY 16 GIVING WS-NIB REMAINDER L-BLOCK
             ELSE
                 DIVIDE WS-BYTE BY 16 GIVING L-BLOCK
             END-IF
*>           CC-0007 stopgap (sky-stopgap.cob): the sky light assumed where the core sent none (0); remove with it.
             IF L-SKY = 0
                 CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-NX WS-NY WS-NZ L-SKY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MESH-CELL.
