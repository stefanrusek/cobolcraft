*> The ender dragon's flight graph (docs/protocol/21 section 6.4.2, 44 part 9 section 1.2; lane 002-lane-mobsb8, T9700): the 24 nodes (the positions of the docs' oracle table, the adjacency masks),
*> their heights (DRAGON-NODES-INIT: the surface column + 5 / 15 / 5, at least 73), the nearest node (the outer ring is excluded once no crystal lives), the A* path (DG-PATH-* of DRAGSTATE.cpy, the
*> extra goal node appended as node 24) and navigateToNextPathNode (target = node + a random height 0 to 20). Gap: the surface is the first non-air block from the top (no leaves, fluids are blocks).
*>
*>   DRAGON-NODE-XZ USING node (0 to 23), x out, z out (BINARY-LONG)
*>   DRAGON-NODE-ADJ USING node, adjacency mask out (bit j = an edge to node j)
*>   DRAGON-SURFACE USING dim, x, z, y out: one above the top non-air block of the column (0 when empty)
*>   DRAGON-NODES-INIT USING dim: DG-NODE-Y of the 24 nodes
*>   DRAGON-NODE-POS USING node (0 to 24), x, y, z out (FLOAT-LONG; 24 is the extra node of the path)
*>   DRAGON-CLOSEST USING x, y, z (FLOAT-LONG), living crystals, node out
*>   DRAGON-PATH USING from, to, extra (0 or 1), extra x, y, z, living crystals: findPath into DG-PATH-*, DG-HAS-PATH 0 when from = to without an extra node
*>   DRAGON-NAV: navigateToNextPathNode (the next node becomes the target)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-NODE-XZ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NXS.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 60.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 51.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -31.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -52.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -60.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -52.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -30.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 51.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 40.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 28.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -40.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 28.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 20.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -20.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
 01 WS-NXT REDEFINES WS-NXS.
    05 WS-NX               PIC S9(3) SIGN LEADING SEPARATE OCCURS 24 TIMES.
 01 WS-NZS.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 30.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 51.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 60.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 51.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -31.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -52.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -60.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -52.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -30.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 28.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 40.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 28.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -40.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -29.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 20.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC S9(3) SIGN LEADING SEPARATE VALUE -20.
 01 WS-NZT REDEFINES WS-NZS.
    05 WS-NZ               PIC S9(3) SIGN LEADING SEPARATE OCCURS 24 TIMES.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Z.
     MOVE WS-NX(L-NODE + 1) TO L-X
     MOVE WS-NZ(L-NODE + 1) TO L-Z
     GOBACK.
 END PROGRAM DRAGON-NODE-XZ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-NODE-ADJ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NMS.
    05 FILLER              PIC 9(8) VALUE 6146.
    05 FILLER              PIC 9(8) VALUE 8197.
    05 FILLER              PIC 9(8) VALUE 8202.
    05 FILLER              PIC 9(8) VALUE 16404.
    05 FILLER              PIC 9(8) VALUE 32808.
    05 FILLER              PIC 9(8) VALUE 32848.
    05 FILLER              PIC 9(8) VALUE 65696.
    05 FILLER              PIC 9(8) VALUE 131392.
    05 FILLER              PIC 9(8) VALUE 131712.
    05 FILLER              PIC 9(8) VALUE 263424.
    05 FILLER              PIC 9(8) VALUE 526848.
    05 FILLER              PIC 9(8) VALUE 525313.
    05 FILLER              PIC 9(8) VALUE 1581057.
    05 FILLER              PIC 9(8) VALUE 3166214.
    05 FILLER              PIC 9(8) VALUE 2138120.
    05 FILLER              PIC 9(8) VALUE 6373424.
    05 FILLER              PIC 9(8) VALUE 4358208.
    05 FILLER              PIC 9(8) VALUE 12910976.
    05 FILLER              PIC 9(8) VALUE 9044480.
    05 FILLER              PIC 9(8) VALUE 9706496.
    05 FILLER              PIC 9(8) VALUE 15216640.
    05 FILLER              PIC 9(8) VALUE 13688832.
    05 FILLER              PIC 9(8) VALUE 11763712.
    05 FILLER              PIC 9(8) VALUE 8257536.
 01 WS-NMT REDEFINES WS-NMS.
    05 WS-NM               PIC 9(8) OCCURS 24 TIMES.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-MASK.
     MOVE WS-NM(L-NODE + 1) TO L-MASK
     GOBACK.
 END PROGRAM DRAGON-NODE-ADJ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-Y.
     MOVE 0 TO L-Y
     PERFORM VARYING WS-Y FROM 255 BY -1 UNTIL WS-Y < 0 OR L-Y > 0
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
         IF WS-STATE NOT = 0
             COMPUTE L-Y = WS-Y + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-NODES-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 23
         CALL "DRAGON-NODE-XZ" USING WS-I WS-X WS-Z
         CALL "DRAGON-SURFACE" USING L-DIM WS-X WS-Z WS-SURFACE
         MOVE 5 TO WS-ABOVE
         IF WS-I >= 12 AND WS-I <= 19
             MOVE 15 TO WS-ABOVE
         END-IF
         COMPUTE DG-NODE-Y(WS-I + 1) = FUNCTION MAX(73, WS-SURFACE + WS-ABOVE)
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-NODES-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-NODE-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z.
     IF L-NODE = 24
         MOVE DG-EX TO L-X
         MOVE DG-EY TO L-Y
         MOVE DG-EZ TO L-Z
         GOBACK
     END-IF
     CALL "DRAGON-NODE-XZ" USING L-NODE WS-X WS-Z
     MOVE WS-X TO L-X
     MOVE DG-NODE-Y(L-NODE + 1) TO L-Y
     MOVE WS-Z TO L-Z
     GOBACK.
 END PROGRAM DRAGON-NODE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-CLOSEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-CRYSTALS             BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CRYSTALS L-NODE.
     MOVE 12 TO WS-S
     IF L-CRYSTALS > 0
         MOVE 0 TO WS-S
     END-IF
     MOVE WS-S TO L-NODE
     MOVE 1.0E+30 TO WS-BEST
     PERFORM VARYING WS-I FROM WS-S BY 1 UNTIL WS-I > 23
         CALL "DRAGON-NODE-POS" USING WS-I WS-NX WS-NY WS-NZ
         COMPUTE WS-D2 = (WS-NX - L-X) ** 2 + (WS-NY - L-Y) ** 2 + (WS-NZ - L-Z) ** 2
         IF WS-D2 < WS-BEST
             MOVE WS-D2 TO WS-BEST
             MOVE WS-I TO L-NODE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-CLOSEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-PATH.
*> A* over the allowed nodes (s to 23, s = 12 without crystals); an unreachable goal gives the path to the explored node nearest to it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-G                   FLOAT-LONG OCCURS 24 TIMES.
 01 WS-F                   FLOAT-LONG OCCURS 24 TIMES.
 01 WS-OPEN                BINARY-LONG OCCURS 24 TIMES.
 01 WS-CLOSED              BINARY-LONG OCCURS 24 TIMES.
 01 WS-PARENT              BINARY-LONG OCCURS 24 TIMES.
 01 WS-REV                 BINARY-LONG OCCURS 26 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-QUOT                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-GOALX               FLOAT-LONG.
 01 WS-GOALY               FLOAT-LONG.
 01 WS-GOALZ               FLOAT-LONG.
 01 WS-CAND                FLOAT-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-EZ                   BINARY-LONG.
 01 L-CRYSTALS             BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-EXTRA L-EX L-EY L-EZ L-CRYSTALS.
     MOVE 0 TO DG-HAS-PATH DG-PATH-N
     MOVE 1 TO DG-PATH-I
     IF L-EXTRA = 1
         MOVE L-EX TO DG-EX
         MOVE L-EY TO DG-EY
         MOVE L-EZ TO DG-EZ
     END-IF
     IF L-FROM = L-TO AND L-EXTRA = 0
         GOBACK
     END-IF
     MOVE 12 TO WS-S
     IF L-CRYSTALS > 0
         MOVE 0 TO WS-S
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE 0 TO WS-OPEN(WS-I) WS-CLOSED(WS-I) WS-PARENT(WS-I) WS-G(WS-I) WS-F(WS-I)
     END-PERFORM
     CALL "DRAGON-NODE-POS" USING L-TO WS-GOALX WS-GOALY WS-GOALZ
     CALL "DRAGON-NODE-POS" USING L-FROM WS-AX WS-AY WS-AZ
     COMPUTE WS-F(L-FROM + 1) = FUNCTION SQRT((WS-AX - WS-GOALX) ** 2 + (WS-AY - WS-GOALY) ** 2 + (WS-AZ - WS-GOALZ) ** 2)
     MOVE 1 TO WS-OPEN(L-FROM + 1)
     MOVE 0 TO WS-FOUND
     PERFORM UNTIL WS-FOUND = 1
         MOVE 1.0E+30 TO WS-BEST
         MOVE -1 TO WS-CUR
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 23
             IF WS-OPEN(WS-I + 1) = 1 AND WS-F(WS-I + 1) < WS-BEST
                 MOVE WS-F(WS-I + 1) TO WS-BEST
                 MOVE WS-I TO WS-CUR
             END-IF
         END-PERFORM
         IF WS-CUR < 0
             MOVE 2 TO WS-FOUND
         ELSE
             IF WS-CUR = L-TO
                 MOVE 1 TO WS-FOUND
             ELSE
                 MOVE 0 TO WS-OPEN(WS-CUR + 1)
                 MOVE 1 TO WS-CLOSED(WS-CUR + 1)
                 CALL "DRAGON-NODE-ADJ" USING WS-CUR WS-MASK
                 CALL "DRAGON-NODE-POS" USING WS-CUR WS-AX WS-AY WS-AZ
                 PERFORM VARYING WS-J FROM WS-S BY 1 UNTIL WS-J > 23
                     COMPUTE WS-QUOT = WS-MASK / 2 ** WS-J
                     COMPUTE WS-BIT = FUNCTION MOD(WS-QUOT, 2)
                     IF WS-BIT = 1 AND WS-CLOSED(WS-J + 1) = 0
                         CALL "DRAGON-NODE-POS" USING WS-J WS-BX WS-BY WS-BZ
                         COMPUTE WS-CAND = WS-G(WS-CUR + 1) + FUNCTION SQRT((WS-AX - WS-BX) ** 2 + (WS-AY - WS-BY) ** 2 + (WS-AZ - WS-BZ) ** 2)
                         IF WS-OPEN(WS-J + 1) = 0 OR WS-CAND < WS-G(WS-J + 1)
                             MOVE WS-CAND TO WS-G(WS-J + 1)
                             MOVE WS-CUR TO WS-PARENT(WS-J + 1)
                             COMPUTE WS-F(WS-J + 1) = WS-CAND + FUNCTION SQRT((WS-BX - WS-GOALX) ** 2 + (WS-BY - WS-GOALY) ** 2 + (WS-BZ - WS-GOALZ) ** 2)
                             MOVE 1 TO WS-OPEN(WS-J + 1)
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
*>   The end node: the goal, or (unreachable) the explored node nearest to it; the path is read back along the parents.
     MOVE L-TO TO WS-END
     IF WS-FOUND = 2
         MOVE 1.0E+30 TO WS-BEST
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 23
             IF WS-CLOSED(WS-I + 1) = 1
                 CALL "DRAGON-NODE-POS" USING WS-I WS-AX WS-AY WS-AZ
                 COMPUTE WS-CAND = (WS-AX - WS-GOALX) ** 2 + (WS-AY - WS-GOALY) ** 2 + (WS-AZ - WS-GOALZ) ** 2
                 IF WS-CAND < WS-BEST
                     MOVE WS-CAND TO WS-BEST
                     MOVE WS-I TO WS-END
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     MOVE 0 TO WS-N
     MOVE WS-END TO WS-CUR
     PERFORM UNTIL WS-CUR = L-FROM
         ADD 1 TO WS-N
         MOVE WS-CUR TO WS-REV(WS-N)
         MOVE WS-PARENT(WS-CUR + 1) TO WS-CUR
     END-PERFORM
     ADD 1 TO WS-N
     MOVE L-FROM TO WS-REV(WS-N)
     MOVE 0 TO DG-PATH-N
     PERFORM VARYING WS-I FROM WS-N BY -1 UNTIL WS-I < 1
         ADD 1 TO DG-PATH-N
         MOVE WS-REV(WS-I) TO DG-PATH-NODE(DG-PATH-N)
     END-PERFORM
     IF L-EXTRA = 1
         ADD 1 TO DG-PATH-N
         MOVE 24 TO DG-PATH-NODE(DG-PATH-N)
     END-IF
     MOVE 1 TO DG-HAS-PATH
     GOBACK.
 END PROGRAM DRAGON-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-NAV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 01 WS-NODE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9141.
 01 WS-K                   BINARY-LONG VALUE 1000.
 01 WS-R                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF DG-HAS-PATH = 1 AND DG-PATH-I <= DG-PATH-N
         MOVE DG-PATH-NODE(DG-PATH-I) TO WS-NODE
         ADD 1 TO DG-PATH-I
         CALL "DRAGON-NODE-POS" USING WS-NODE WS-X WS-Y WS-Z
         CALL "XP-RANDOM" USING WS-SALT WS-K WS-R
         MOVE WS-X TO DG-TX
         COMPUTE DG-TY = WS-Y + WS-R / 1000 * 20
         MOVE WS-Z TO DG-TZ
         MOVE 1 TO DG-HAS-TARGET
     END-IF
     GOBACK.
 END PROGRAM DRAGON-NAV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-WRAP.
*> USING angle in degrees (FLOAT-LONG, in and out): Mth.wrapDegrees, -180 (included) to 180 (excluded).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ANGLE.
     COMPUTE L-ANGLE = FUNCTION MOD(L-ANGLE, 360)
     IF L-ANGLE >= 180
         COMPUTE L-ANGLE = L-ANGLE - 360
     END-IF
     GOBACK.
 END PROGRAM DRAGON-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-ATAN2.
*> USING y, x (FLOAT-LONG), result in degrees (FLOAT-LONG): atan2(y, x).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PI                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-DEG                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-DEG.
     MOVE FUNCTION PI TO WS-PI
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE L-DEG = FUNCTION ATAN(L-Y / L-X) * 180 / WS-PI
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE L-DEG = (FUNCTION ATAN(L-Y / L-X) + WS-PI) * 180 / WS-PI
         WHEN L-X < 0
             COMPUTE L-DEG = (FUNCTION ATAN(L-Y / L-X) - WS-PI) * 180 / WS-PI
         WHEN L-Y > 0
             MOVE 90 TO L-DEG
         WHEN L-Y < 0
             MOVE -90 TO L-DEG
         WHEN OTHER
             MOVE 0 TO L-DEG
     END-EVALUATE
     GOBACK.
 END PROGRAM DRAGON-ATAN2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HIST-PUSH.
*> USING row: the flight history takes this tick's (y, yaw) as its newest sample.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE DG-HIST-I = FUNCTION MOD(DG-HIST-I + 1, 64)
     MOVE EN-Y(L-ROW) TO DG-HIST-Y(DG-HIST-I + 1)
     MOVE EN-YAW(L-ROW) TO DG-HIST-YAW(DG-HIST-I + 1)
     GOBACK.
 END PROGRAM DRAGON-HIST-PUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HIST-GET.
*> USING n (0 to 63), y out, yaw out (FLOAT-LONG): the sample n ticks ago (0 = the newest).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-N L-Y L-YAW.
     COMPUTE WS-IDX = FUNCTION MOD(DG-HIST-I - L-N + 64, 64) + 1
     MOVE DG-HIST-Y(WS-IDX) TO L-Y
     MOVE DG-HIST-YAW(WS-IDX) TO L-YAW
     GOBACK.
 END PROGRAM DRAGON-HIST-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-MOVE.
*> USING row: one steering and movement step (21 section 6.4.1, steps 1 to 6; the speeds by phase: 0.6, landing 1.5, charging and dying 3.0, hover 1.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-PI                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-HS                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-GL                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 01 WS-TURN                FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-VG                  FLOAT-LONG.
 01 WS-WALLF               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE FUNCTION PI TO WS-PI
     MOVE 0.6 TO WS-S
     EVALUATE DG-PHASE
         WHEN 3
             MOVE 1.5 TO WS-S
         WHEN 8 WHEN 9
             MOVE 3.0 TO WS-S
         WHEN 10
             MOVE 1.0 TO WS-S
     END-EVALUATE
     COMPUTE WS-HS = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     IF DG-PHASE = 3
         COMPUTE WS-T = FUNCTION MIN(WS-HS + 1, 40) / (WS-HS + 1)
     ELSE
         COMPUTE WS-T = (0.7 / FUNCTION MIN(WS-HS + 1, 40)) / (WS-HS + 1)
     END-IF
     MOVE EN-YAW(L-ROW) TO WS-YAW
     COMPUTE WS-RAD = WS-YAW * WS-PI / 180
     COMPUTE WS-GX = FUNCTION SIN(WS-RAD)
     MOVE EN-VY(L-ROW) TO WS-GY
     COMPUTE WS-GZ = 0 - FUNCTION COS(WS-RAD)
     COMPUTE WS-GL = FUNCTION SQRT(WS-GX * WS-GX + WS-GY * WS-GY + WS-GZ * WS-GZ)
     IF DG-HAS-TARGET = 1
         COMPUTE WS-DX = DG-TX - EN-X(L-ROW)
         COMPUTE WS-DY = DG-TY - EN-Y(L-ROW)
         COMPUTE WS-DZ = DG-TZ - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         IF WS-H > 0
             COMPUTE WS-DY = FUNCTION MAX(0 - WS-S, FUNCTION MIN(WS-S, WS-DY / WS-H))
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-DY * 0.01
             COMPUTE WS-DY = DG-TY - EN-Y(L-ROW)
         END-IF
         CALL "DRAGON-WRAP" USING WS-YAW
*>       heading g = normalize(sin(yaw), vy, -cos(yaw)); f = max((g.u + 0.5) / 1.5, 0)
         MOVE EN-VY(L-ROW) TO WS-GY
         COMPUTE WS-GL = FUNCTION SQRT(WS-GX * WS-GX + WS-GY * WS-GY + WS-GZ * WS-GZ)
         COMPUTE WS-D = FUNCTION SQRT(WS-D2)
         MOVE 0 TO WS-F
         IF WS-D > 0 AND WS-GL > 0
             COMPUTE WS-F = FUNCTION MAX(((WS-GX * WS-DX + WS-GY * WS-DY + WS-GZ * WS-DZ) / (WS-GL * WS-D) + 0.5) / 1.5, 0)
         END-IF
         IF FUNCTION ABS(WS-DX) > 0.00001 OR FUNCTION ABS(WS-DZ) > 0.00001
             CALL "DRAGON-ATAN2" USING WS-DX WS-DZ WS-ANG
             COMPUTE WS-TURN = 180 - WS-ANG - WS-YAW
             CALL "DRAGON-WRAP" USING WS-TURN
             COMPUTE WS-TURN = FUNCTION MAX(-50, FUNCTION MIN(50, WS-TURN))
             COMPUTE DG-YROT-A = DG-YROT-A * 0.8 + WS-TURN * WS-T
             COMPUTE WS-YAW = WS-YAW + DG-YROT-A * 0.1
         END-IF
         COMPUTE WS-K = 2 / (WS-D2 + 1)
         COMPUTE WS-SC = 0.06 * (WS-F * WS-K + (1 - WS-K))
         COMPUTE WS-RAD = WS-YAW * WS-PI / 180
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-SC * FUNCTION SIN(WS-RAD)
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) - WS-SC * FUNCTION COS(WS-RAD)
     END-IF
     MOVE 1.0 TO WS-WALLF
     IF DG-WALL = 1
         MOVE 0.8 TO WS-WALLF
     END-IF
     COMPUTE EN-X(L-ROW) = EN-X(L-ROW) + EN-VX(L-ROW) * WS-WALLF
     COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + EN-VY(L-ROW) * WS-WALLF
     COMPUTE EN-Z(L-ROW) = EN-Z(L-ROW) + EN-VZ(L-ROW) * WS-WALLF
     COMPUTE WS-V = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     MOVE 0 TO WS-VG
     IF WS-V > 0 AND WS-GL > 0
         COMPUTE WS-VG = (EN-VX(L-ROW) * WS-GX + EN-VY(L-ROW) * WS-GY + EN-VZ(L-ROW) * WS-GZ) / (WS-V * WS-GL)
     END-IF
     COMPUTE WS-M = 0.8 + 0.15 * (WS-VG + 1) / 2
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * WS-M
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.91
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * WS-M
     MOVE WS-YAW TO EN-YAW(L-ROW)
     GOBACK.
 END PROGRAM DRAGON-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-PART-SIZE.
*> USING part (1 head, 2 neck, 3 body, 4 to 6 tails, 7 and 8 wings), width, height out (FLOAT-LONG): the part boxes of 21 section 6.4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-PART L-W L-H.
     EVALUATE L-PART
         WHEN 1
             MOVE 1 TO L-W
             MOVE 1 TO L-H
         WHEN 2
             MOVE 3 TO L-W
             MOVE 3 TO L-H
         WHEN 3
             MOVE 5 TO L-W
             MOVE 3 TO L-H
         WHEN 4 THRU 6
             MOVE 2 TO L-W
             MOVE 2 TO L-H
         WHEN OTHER
             MOVE 4 TO L-W
             MOVE 2 TO L-H
     END-EVALUATE
     GOBACK.
 END PROGRAM DRAGON-PART-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-PARTS.
*> USING row: DG-PART from the dragon's position, yaw and the flight history (the formulas of 21 section 6.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-PI                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-YH                  FLOAT-LONG.
 01 WS-SH                  FLOAT-LONG.
 01 WS-CH                  FLOAT-LONG.
 01 WS-CP                  FLOAT-LONG.
 01 WS-SP                  FLOAT-LONG.
 01 WS-PT                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y5                  FLOAT-LONG.
 01 WS-Y10                 FLOAT-LONG.
 01 WS-YW5                 FLOAT-LONG.
 01 WS-YW0                 FLOAT-LONG.
 01 WS-YWN                 FLOAT-LONG.
 01 WS-YN                  FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE FUNCTION PI TO WS-PI
     COMPUTE WS-YAW = EN-YAW(L-ROW) * WS-PI / 180
     COMPUTE WS-SY = FUNCTION SIN(WS-YAW)
     COMPUTE WS-CY = FUNCTION COS(WS-YAW)
     MOVE 0 TO WS-N
     CALL "DRAGON-HIST-GET" USING WS-N WS-Y0 WS-YW0
     MOVE 5 TO WS-N
     CALL "DRAGON-HIST-GET" USING WS-N WS-Y5 WS-YW5
     MOVE 10 TO WS-N
     CALL "DRAGON-HIST-GET" USING WS-N WS-Y10 WS-YWN
     COMPUTE WS-PT = (WS-Y5 - WS-Y10) * 10
     COMPUTE WS-CP = FUNCTION COS(WS-PT)
     COMPUTE WS-SP = FUNCTION SIN(WS-PT)
     COMPUTE WS-HY = WS-Y5 - WS-Y0
     IF DG-PHASE = 5 OR DG-PHASE = 6 OR DG-PHASE = 7 OR DG-PHASE = 10
         MOVE -1 TO WS-HY
     END-IF
     COMPUTE WS-YH = WS-YAW - DG-YROT-A * 0.01
     COMPUTE WS-SH = FUNCTION SIN(WS-YH)
     COMPUTE WS-CH = FUNCTION COS(WS-YH)
*>   body 3, wings 7 and 8
     COMPUTE DG-PART-X(3) = EN-X(L-ROW) + WS-SY * 0.5
     MOVE EN-Y(L-ROW) TO DG-PART-Y(3)
     COMPUTE DG-PART-Z(3) = EN-Z(L-ROW) - WS-CY * 0.5
     COMPUTE DG-PART-X(7) = EN-X(L-ROW) + WS-CY * 4.5
     COMPUTE DG-PART-Y(7) = EN-Y(L-ROW) + 2.0
     COMPUTE DG-PART-Z(7) = EN-Z(L-ROW) + WS-SY * 4.5
     COMPUTE DG-PART-X(8) = EN-X(L-ROW) - WS-CY * 4.5
     COMPUTE DG-PART-Y(8) = EN-Y(L-ROW) + 2.0
     COMPUTE DG-PART-Z(8) = EN-Z(L-ROW) - WS-SY * 4.5
*>   head 1, neck 2
     COMPUTE DG-PART-X(1) = EN-X(L-ROW) + WS-SH * 6.5 * WS-CP
     COMPUTE DG-PART-Y(1) = EN-Y(L-ROW) + WS-HY + WS-SP * 6.5
     COMPUTE DG-PART-Z(1) = EN-Z(L-ROW) - WS-CH * 6.5 * WS-CP
     COMPUTE DG-PART-X(2) = EN-X(L-ROW) + WS-SH * 5.5 * WS-CP
     COMPUTE DG-PART-Y(2) = EN-Y(L-ROW) + WS-HY + WS-SP * 5.5
     COMPUTE DG-PART-Z(2) = EN-Z(L-ROW) - WS-CH * 5.5 * WS-CP
*>   tails 4 to 6
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         COMPUTE WS-N = 12 + 2 * WS-I
         CALL "DRAGON-HIST-GET" USING WS-N WS-YN WS-YWN
         COMPUTE WS-L = (WS-I + 1) * 2
         COMPUTE WS-DEG = WS-YWN - WS-YW5
         CALL "DRAGON-WRAP" USING WS-DEG
         COMPUTE WS-A = WS-YAW + WS-DEG * WS-PI / 180
         COMPUTE DG-PART-X(4 + WS-I) = EN-X(L-ROW) - ((WS-SY * 1.5) + FUNCTION SIN(WS-A) * WS-L) * WS-CP
         COMPUTE DG-PART-Y(4 + WS-I) = EN-Y(L-ROW) + (WS-YN - WS-Y5) - (WS-L + 1.5) * WS-SP + 1.5
         COMPUTE DG-PART-Z(4 + WS-I) = EN-Z(L-ROW) + ((WS-CY * 1.5) + FUNCTION COS(WS-A) * WS-L) * WS-CP
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-PARTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-WALLS.
*> USING row, in wall out (0 or 1): checkWalls on the head, neck and body boxes: every non-air block that is not in the transparent tags (light, fire) is removed (mob_griefing on,
*> not dragon_immune) or marks the dragon "in wall"; world event 2008 once when something was removed. Gap: the tags are the lists of the docs, not the data pack's, and the event is at the centre of
*> the last box instead of a random position inside it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DRAGSTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-PART                BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-PATH                PIC X(48).
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 2008.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WALL.
     MOVE 0 TO L-WALL WS-REMOVED
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     PERFORM VARYING WS-PART FROM 1 BY 1 UNTIL WS-PART > 3
         CALL "DRAGON-PART-SIZE" USING WS-PART WS-W WS-H
         COMPUTE WS-HALF = WS-W / 2
         COMPUTE WS-X0 = FUNCTION INTEGER(DG-PART-X(WS-PART) - WS-HALF)
         COMPUTE WS-X1 = FUNCTION INTEGER(DG-PART-X(WS-PART) + WS-HALF)
         COMPUTE WS-Y0 = FUNCTION INTEGER(DG-PART-Y(WS-PART))
         COMPUTE WS-Y1 = FUNCTION INTEGER(DG-PART-Y(WS-PART) + WS-H)
         COMPUTE WS-Z0 = FUNCTION INTEGER(DG-PART-Z(WS-PART) - WS-HALF)
         COMPUTE WS-Z1 = FUNCTION INTEGER(DG-PART-Z(WS-PART) + WS-HALF)
         PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
                 PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                     IF WS-STATE NOT = 0
                         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
                         IF WS-KEY(1:10) = "minecraft:"
                             MOVE WS-KEY(11:38) TO WS-PATH
                         ELSE
                             MOVE WS-KEY TO WS-PATH
                         END-IF
                         MOVE 0 TO WS-IMMUNE WS-SKIP
                         EVALUATE WS-PATH
                             WHEN "light" WHEN "fire" WHEN "soul_fire"
                                 MOVE 1 TO WS-SKIP
                             WHEN "barrier" WHEN "bedrock" WHEN "end_portal" WHEN "end_portal_frame" WHEN "end_gateway"
                             WHEN "command_block" WHEN "repeating_command_block" WHEN "chain_command_block"
                             WHEN "structure_block" WHEN "jigsaw" WHEN "moving_piston" WHEN "obsidian" WHEN "crying_obsidian"
                             WHEN "end_stone" WHEN "iron_bars" WHEN "respawn_anchor" WHEN "reinforced_deepslate"
                             WHEN "test_block" WHEN "test_instance_block"
                                 MOVE 1 TO WS-IMMUNE
                         END-EVALUATE
                         IF WS-SKIP = 0
                             IF WS-IMMUNE = 1 OR WS-RULE = 0
                                 MOVE 1 TO L-WALL
                             ELSE
                                 CALL "BLOCK-CHANGE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AIR
                                 MOVE 1 TO WS-REMOVED
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-REMOVED = 1
         CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-EVENT WS-X WS-Y WS-Z WS-NONE WS-NONE2
     END-IF
     GOBACK.
 END PROGRAM DRAGON-WALLS.
