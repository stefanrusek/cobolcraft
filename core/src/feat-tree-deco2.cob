*> The remaining tree decorators (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 3.3; the early exits and draws of 3.2): beehive (kind 5), alter_ground (6),
*> place_on_ground (7), shelf_mushroom (8), attached_to_leaves (9), pale_moss (10) and creaking_heart (11), run by FR-DECORATE (feat-tree-deco.cob) over the work area of TREEWORK.cpy.
*> Block states are looked up by name and property text (BLOCKS-STATE-OF over the open content set) when a decorator places them. Deviation (recorded on T8601): the beehive's bees are not
*> stored (the generator writes no block entity), the occupant draws (2 + nextInt(2), then nextInt(599) each) are made so the random stream stays the game's.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-STATE.
*> USING key (PIC X(112)), property pairs (PIC X(160), "name=value,..."), state out (0 when the set has no such block).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAIRS                PIC X(160).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     CALL "BLOCKS-STATE-OF" USING L-KEY L-PAIRS L-STATE
     GOBACK.
 END PROGRAM FR-DEC-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-AIR.
*> USING x, y, z, flag out: 1 when the cell is air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO L-FLAG
     IF WS-CLASS = 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-AIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-HDIR.
*> USING ordinal (0 north, 1 east, 2 south, 3 west: the order of Direction.Plane.HORIZONTAL), dx out, dz out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-DX L-DZ.
     MOVE 0 TO L-DX L-DZ
     EVALUATE L-ORD
         WHEN 0
             MOVE -1 TO L-DZ
         WHEN 1
             MOVE 1 TO L-DX
         WHEN 2
             MOVE 1 TO L-DZ
         WHEN OTHER
             MOVE -1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-DEC-HDIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SHUFFLE-L.
*> USING state, count: TW-SHL = a shuffled copy of TW-LFS(1 .. count) (Collections.shuffle, as FR-DEC-SHUFFLE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-N.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         MOVE TW-LFS(WS-I) TO TW-SHL(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-N BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         MOVE TW-SHL(WS-J + 1) TO WS-T
         MOVE TW-SHL(WS-I) TO TW-SHL(WS-J + 1)
         MOVE WS-T TO TW-SHL(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-SHUFFLE-L.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-LOWEST.
*> USING (nothing): TW-LL(1 .. TW-NLL) = the lowest layer of getLowestTrunkOrRootOfTree (3.1): the roots (the root list sorted by y) when there are no logs, or the first root and first log differ in y;
*> the logs when there are no roots; the logs then the roots when the first of each has the same y; then only the positions at the y of the first of that list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FIRST-Y             BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LOGS                BINARY-LONG.
 01 WS-ROOTS               BINARY-LONG.
 PROCEDURE DIVISION.
*>   the roots sorted by y, positions of equal y in the order placed
     MOVE 0 TO WS-N
     MOVE 999999 TO WS-MIN
     MOVE -999999 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NRL
         IF TW-RL-Y(WS-I) < WS-MIN
             MOVE TW-RL-Y(WS-I) TO WS-MIN
         END-IF
         IF TW-RL-Y(WS-I) > WS-MAX
             MOVE TW-RL-Y(WS-I) TO WS-MAX
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-MIN BY 1 UNTIL WS-Y > WS-MAX
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NRL
             IF TW-RL-Y(WS-I) = WS-Y
                 ADD 1 TO WS-N
                 MOVE WS-I TO TW-RS(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "FR-DEC-SORT"
     MOVE 0 TO WS-RY WS-LY
     IF TW-NRL > 0
         MOVE TW-RS(1) TO WS-K
         MOVE TW-RL-Y(WS-K) TO WS-RY
     END-IF
     IF TW-NLOG > 0
         MOVE TW-LS(1) TO WS-K
         MOVE TW-LOG-Y(WS-K) TO WS-LY
     END-IF
     MOVE 0 TO WS-LOGS WS-ROOTS
     EVALUATE TRUE
         WHEN TW-NRL = 0
             MOVE 1 TO WS-LOGS
         WHEN TW-NLOG > 0 AND WS-RY = WS-LY
             MOVE 1 TO WS-LOGS WS-ROOTS
         WHEN OTHER
             MOVE 1 TO WS-ROOTS
     END-EVALUATE
     MOVE 0 TO TW-NLL
     IF WS-LOGS = 1 AND TW-NLOG > 0
         MOVE WS-LY TO WS-FIRST-Y
     ELSE
         IF TW-NRL > 0
             MOVE WS-RY TO WS-FIRST-Y
         ELSE
             GOBACK
         END-IF
     END-IF
     IF WS-LOGS = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
             MOVE TW-LS(WS-I) TO WS-K
             IF TW-LOG-Y(WS-K) = WS-FIRST-Y
                 ADD 1 TO TW-NLL
                 MOVE TW-LOG-X(WS-K) TO TW-LL-X(TW-NLL)
                 MOVE TW-LOG-Y(WS-K) TO TW-LL-Y(TW-NLL)
                 MOVE TW-LOG-Z(WS-K) TO TW-LL-Z(TW-NLL)
             END-IF
         END-PERFORM
     END-IF
     IF WS-ROOTS = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NRL
             MOVE TW-RS(WS-I) TO WS-K
             IF TW-RL-Y(WS-K) = WS-FIRST-Y
                 ADD 1 TO TW-NLL
                 MOVE TW-RL-X(WS-K) TO TW-LL-X(TW-NLL)
                 MOVE TW-RL-Y(WS-K) TO TW-LL-Y(TW-NLL)
                 MOVE TW-RL-Z(WS-K) TO TW-LL-Z(TW-NLL)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-LOWEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-BEEHIVE.
*> USING state, row, slot: beehive (3.3): no logs ends it before any draw; nextFloat() at or above the probability ends it; the nest's y is max(lowest leaf y - 1, lowest log y + 1), or with no leaves
*> min(lowest log y + 1 + nextInt(3), highest log y); the candidates are the east, south and west cells of the logs at that y, shuffled; the first with it and the cell south of it both air takes the
*> bee_nest facing south; then the occupants' draws (2 + nextInt(2) of them, nextInt(599) each).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:bee_nest".
 01 WS-PAIRS               PIC X(160) VALUE "facing=south,honey_level=0".
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LOW-LOG             BINARY-LONG.
 01 WS-HIGH-LOG            BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-AIR1                BINARY-LONG.
 01 WS-AIR2                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TICKS               BINARY-LONG VALUE 599.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     IF TW-NLOG = 0
         GOBACK
     END-IF
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F >= WS-P
         GOBACK
     END-IF
     MOVE TW-LS(1) TO WS-K
     MOVE TW-LOG-Y(WS-K) TO WS-LOW-LOG
     MOVE TW-LS(TW-NLOG) TO WS-K
     MOVE TW-LOG-Y(WS-K) TO WS-HIGH-LOG
     IF TW-NLEAF > 0
         CALL "FR-DEC-SORTL"
         MOVE TW-LFS(1) TO WS-K
         COMPUTE WS-Y = FUNCTION MAX(TW-LEAF-Y(WS-K) - 1, WS-LOW-LOG + 1)
     ELSE
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-D
         COMPUTE WS-Y = FUNCTION MIN(WS-LOW-LOG + 1 + WS-D, WS-HIGH-LOG)
     END-IF
     MOVE 0 TO TW-NCAND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TW-LS(WS-I) TO WS-K
         IF TW-LOG-Y(WS-K) = WS-Y
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
                 CALL "FR-DEC-HDIR" USING WS-D WS-DX WS-DZ
                 ADD 1 TO TW-NCAND
                 COMPUTE TW-CAND-X(TW-NCAND) = TW-LOG-X(WS-K) + WS-DX
                 MOVE WS-Y TO TW-CAND-Y(TW-NCAND)
                 COMPUTE TW-CAND-Z(TW-NCAND) = TW-LOG-Z(WS-K) + WS-DZ
             END-PERFORM
         END-IF
     END-PERFORM
     IF TW-NCAND = 0
         GOBACK
     END-IF
*>   Collections.shuffle of the candidates
     PERFORM VARYING WS-I FROM TW-NCAND BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         ADD 1 TO WS-J
         MOVE TW-CAND-X(WS-J) TO WS-T
         MOVE TW-CAND-X(WS-I) TO TW-CAND-X(WS-J)
         MOVE WS-T TO TW-CAND-X(WS-I)
         MOVE TW-CAND-Z(WS-J) TO WS-T
         MOVE TW-CAND-Z(WS-I) TO TW-CAND-Z(WS-J)
         MOVE WS-T TO TW-CAND-Z(WS-I)
     END-PERFORM
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NCAND OR WS-DONE = 1
         MOVE TW-CAND-X(WS-I) TO WS-PX
         MOVE TW-CAND-Z(WS-I) TO WS-PZ
         COMPUTE WS-SZ = WS-PZ + 1
         CALL "FR-DEC-AIR" USING WS-PX WS-Y WS-PZ WS-AIR1
         CALL "FR-DEC-AIR" USING WS-PX WS-Y WS-SZ WS-AIR2
         IF WS-AIR1 = 1 AND WS-AIR2 = 1
             MOVE 1 TO WS-DONE
             CALL "FR-DEC-STATE" USING WS-KEY WS-PAIRS WS-STATE
             IF WS-STATE > 0
                 CALL "FL-SET-STATE" USING WS-PX WS-Y WS-PZ WS-STATE WS-FLAGS WS-OK
             END-IF
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-N
             ADD 2 TO WS-N
             PERFORM WS-N TIMES
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TICKS WS-D
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-BEEHIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-ALTER.
*> USING state, row, slot: alter_ground (3.3): over the lowest layer (FR-DEC-LOWEST; nothing when it is empty), for each position four circles at (-1, -1), (+2, -1), (-1, +2), (+2, +2), then five times
*> r = nextInt(64), a = r mod 8, b = r div 8 and a circle at (a - 3, b - 3) when a or b is 0 or 7. A circle is the 5 x 5 cells without its corners, each a ground column: for dy = 2 down to -3 the provider's
*> optional state at the cell is set and ends the column; else a cell that is not air ends it when dy is below 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-64                  BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     CALL "FR-DEC-LOWEST"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLL
         PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
             EVALUATE WS-C
                 WHEN 0
                     COMPUTE WS-CX = TW-LL-X(WS-I) - 1
                     COMPUTE WS-CZ = TW-LL-Z(WS-I) - 1
                 WHEN 1
                     COMPUTE WS-CX = TW-LL-X(WS-I) + 2
                     COMPUTE WS-CZ = TW-LL-Z(WS-I) - 1
                 WHEN 2
                     COMPUTE WS-CX = TW-LL-X(WS-I) - 1
                     COMPUTE WS-CZ = TW-LL-Z(WS-I) + 2
                 WHEN OTHER
                     COMPUTE WS-CX = TW-LL-X(WS-I) + 2
                     COMPUTE WS-CZ = TW-LL-Z(WS-I) + 2
             END-EVALUATE
             PERFORM CIRCLE
         END-PERFORM
         PERFORM 5 TIMES
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-64 WS-R
             COMPUTE WS-A = FUNCTION MOD(WS-R, 8)
             COMPUTE WS-B = WS-R / 8
             IF WS-A = 0 OR WS-A = 7 OR WS-B = 0 OR WS-B = 7
                 COMPUTE WS-CX = TW-LL-X(WS-I) + WS-A - 3
                 COMPUTE WS-CZ = TW-LL-Z(WS-I) + WS-B - 3
                 PERFORM CIRCLE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 CIRCLE.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             IF NOT ((WS-DX = 2 OR WS-DX = -2) AND (WS-DZ = 2 OR WS-DZ = -2))
                 COMPUTE WS-QX = WS-CX + WS-DX
                 COMPUTE WS-QZ = WS-CZ + WS-DZ
                 PERFORM GROUND-COLUMN
             END-IF
         END-PERFORM
     END-PERFORM
     .
 GROUND-COLUMN.
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-DY FROM 2 BY -1 UNTIL WS-DY < -3 OR WS-STOP = 1
         COMPUTE WS-TY = TW-LL-Y(WS-I) + WS-DY
         CALL "FR-PROV-STATE" USING L-STATE TD-PV(L-ROW, L-SLOT) WS-QX WS-TY WS-QZ WS-NEW WS-OK
         IF WS-OK = 1
             CALL "FL-SET-STATE" USING WS-QX WS-TY WS-QZ WS-NEW WS-FLAGS WS-OK
             MOVE 1 TO WS-STOP
         ELSE
             CALL "FL-GET-STATE" USING WS-QX WS-TY WS-QZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS NOT = 1 AND WS-DY < 0
                 MOVE 1 TO WS-STOP
             END-IF
         END-IF
     END-PERFORM
     .
 END PROGRAM FR-DEC-ALTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-PLACE.
*> USING state, row, slot: place_on_ground (3.3): the box of the lowest layer's x and z extent at its y, inflated by radius in x and z and by height in y; tries times x, y, z are each drawn as
*> nextIntBetweenInclusive(min, max) in that order; at q the provider's state goes to the cell above q iff that cell is air or a vine, q is an opaque block (isSolidRender: CB-OPAQUE) and the MOTION_BLOCKING_NO_LEAVES height at
*> q is at most the cell's y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY CBLOCKS.
 01 WS-VINE                PIC X(48) VALUE "minecraft:vine".
 01 WS-VINE-B              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG VALUE 5.
 01 WS-H                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     CALL "FR-DEC-LOWEST"
     IF TW-NLL = 0
         GOBACK
     END-IF
     CALL "FD-BLOCK-INDEX" USING WS-VINE WS-VINE-B
     MOVE TW-LL-X(1) TO WS-MINX WS-MAXX
     MOVE TW-LL-Z(1) TO WS-MINZ WS-MAXZ
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > TW-NLL
         IF TW-LL-X(WS-I) < WS-MINX
             MOVE TW-LL-X(WS-I) TO WS-MINX
         END-IF
         IF TW-LL-X(WS-I) > WS-MAXX
             MOVE TW-LL-X(WS-I) TO WS-MAXX
         END-IF
         IF TW-LL-Z(WS-I) < WS-MINZ
             MOVE TW-LL-Z(WS-I) TO WS-MINZ
         END-IF
         IF TW-LL-Z(WS-I) > WS-MAXZ
             MOVE TW-LL-Z(WS-I) TO WS-MAXZ
         END-IF
     END-PERFORM
     COMPUTE WS-MINX = WS-MINX - TD-I(L-ROW, L-SLOT, 2)
     COMPUTE WS-MAXX = WS-MAXX + TD-I(L-ROW, L-SLOT, 2)
     COMPUTE WS-MINZ = WS-MINZ - TD-I(L-ROW, L-SLOT, 2)
     COMPUTE WS-MAXZ = WS-MAXZ + TD-I(L-ROW, L-SLOT, 2)
     COMPUTE WS-MINY = TW-LL-Y(1) - TD-I(L-ROW, L-SLOT, 3)
     COMPUTE WS-MAXY = TW-LL-Y(1) + TD-I(L-ROW, L-SLOT, 3)
     PERFORM TD-I(L-ROW, L-SLOT, 1) TIMES
         COMPUTE WS-SPAN = WS-MAXX - WS-MINX + 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-D
         COMPUTE WS-QX = WS-MINX + WS-D
         COMPUTE WS-SPAN = WS-MAXY - WS-MINY + 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-D
         COMPUTE WS-QY = WS-MINY + WS-D
         COMPUTE WS-SPAN = WS-MAXZ - WS-MINZ + 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-D
         COMPUTE WS-QZ = WS-MINZ + WS-D
         COMPUTE WS-AY = WS-QY + 1
         MOVE 0 TO WS-PASS
         CALL "FL-GET-STATE" USING WS-QX WS-AY WS-QZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         IF WS-CLASS = 1 OR (WS-BLOCK > 0 AND WS-BLOCK = WS-VINE-B)
             CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-BLOCK > 0 AND WS-CLASS NOT = 1
                 IF CB-OPAQUE(WS-BLOCK) = 1
                     CALL "FL-HEIGHT-OF" USING WS-ORD WS-QX WS-QZ WS-H
                     IF WS-H <= WS-AY
                         MOVE 1 TO WS-PASS
                     END-IF
                 END-IF
             END-IF
         END-IF
         IF WS-PASS = 1
             CALL "FR-PROV-STATE" USING L-STATE TD-PV(L-ROW, L-SLOT) WS-QX WS-AY WS-QZ WS-NEW WS-OK
             IF WS-OK = 1
                 CALL "FL-SET-STATE" USING WS-QX WS-AY WS-QZ WS-NEW WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SHELF-OK.
*> USING x, y, z, flag out: shelf-replaceable (3.3): the cell can be replaced (air, or a block the table marks replaceable: CB-REPLACEABLE) and neither it nor one of its four horizontal
*> neighbours is water.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-HAS
     IF WS-CLASS = 1
         MOVE 1 TO WS-HAS
     END-IF
     IF WS-BLOCK > 0
         IF CB-REPLACEABLE(WS-BLOCK) = 1 AND WS-CLASS NOT = 2
             MOVE 1 TO WS-HAS
         END-IF
     END-IF
     IF WS-HAS = 1
         MOVE 1 TO L-FLAG
         PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
             CALL "FR-DEC-HDIR" USING WS-D WS-DX WS-DZ
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NZ = L-Z + WS-DZ
             CALL "FL-GET-STATE" USING WS-NX L-Y WS-NZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 2
                 MOVE 0 TO L-FLAG
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-SHELF-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SHELF-AT.
*> USING x, y, z (a shelf_mushroom block?), flag out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:shelf_mushroom".
 01 WS-B                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-B
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-B > 0 AND WS-BLOCK = WS-B
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-SHELF-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-SHELF.
*> USING state, row, slot: shelf_mushroom (3.3): nextFloat() at or above the probability ends it, then no logs. The tree is a fallen log when the first and last log of the sorted list have the same y.
*> Standing: one draw over north, east, south, west gives d, the pair is (d, clockwise d); for the logs 1 to 4 above the first, each direction of the pair draws nextFloat() and a value at most 0.25 tries a
*> placement, a success ends the directions of that log. Fallen: the pair is north and south when the first and last log differ in x, else east and west; every direction of every log draws and tries
*> (no early end), a try also fails beside another shelf_mushroom (round the cell or round the log). A placement is shelf_mushroom with age nextInt(2) and the facing of the direction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:shelf_mushroom".
 01 WS-PAIRS               PIC X(160).
 01 WS-FACE.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west".
 01 WS-FACE-T REDEFINES WS-FACE.
    05 WS-FACE-N           PIC X(5) OCCURS 4 TIMES.
 01 WS-PAIR.
    05 WS-PD               BINARY-LONG OCCURS 2 TIMES.
 01 WS-FALLEN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-FN                  PIC X(5).
 01 WS-FIRSTL              BINARY-LONG.
 01 WS-LASTL               BINARY-LONG.
 01 WS-TS                  BINARY-LONG.
 01 WS-TN                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-AGE-TEXT            PIC 9.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F >= WS-P OR TW-NLOG = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-FALLEN
     MOVE TW-LS(1) TO WS-FIRSTL
     MOVE TW-LS(TW-NLOG) TO WS-LASTL
     IF TW-LOG-Y(WS-FIRSTL) = TW-LOG-Y(WS-LASTL)
         MOVE 1 TO WS-FALLEN
     END-IF
     IF WS-FALLEN = 1
         IF TW-LOG-X(WS-FIRSTL) NOT = TW-LOG-X(WS-LASTL)
             MOVE 0 TO WS-PD(1)
             MOVE 2 TO WS-PD(2)
         ELSE
             MOVE 1 TO WS-PD(1)
             MOVE 3 TO WS-PD(2)
         END-IF
     ELSE
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-D
         MOVE WS-D TO WS-PD(1)
         COMPUTE WS-PD(2) = FUNCTION MOD(WS-D + 1, 4)
     END-IF
     MOVE TW-LOG-Y(WS-FIRSTL) TO WS-BASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TW-LS(WS-I) TO WS-K
         IF WS-FALLEN = 1 OR (TW-LOG-Y(WS-K) - WS-BASE >= 1 AND TW-LOG-Y(WS-K) - WS-BASE <= 4)
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2 OR WS-DONE = 1
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 IF WS-F <= WS-QUARTER
                     MOVE WS-PD(WS-J) TO WS-D
                     CALL "FR-DEC-HDIR" USING WS-D WS-DX WS-DZ
                     COMPUTE WS-PX = TW-LOG-X(WS-K) + WS-DX
                     COMPUTE WS-PZ = TW-LOG-Z(WS-K) + WS-DZ
                     PERFORM TRY-PLACE
                     IF WS-FALLEN = 0 AND WS-OK = 1
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 TRY-PLACE.
     MOVE 0 TO WS-OK
     CALL "FR-DEC-SHELF-OK" USING WS-PX TW-LOG-Y(WS-K) WS-PZ WS-GOOD
     IF WS-GOOD = 1
         MOVE 0 TO WS-BAD
         IF WS-FALLEN = 0
             COMPUTE WS-BELOW = TW-LOG-Y(WS-K) - 1
             CALL "FR-DEC-SHELF-AT" USING WS-PX WS-BELOW WS-PZ WS-BAD
         ELSE
             PERFORM VARYING WS-M FROM 0 BY 1 UNTIL WS-M > 3
                 CALL "FR-DEC-HDIR" USING WS-M WS-NX WS-NZ
                 COMPUTE WS-NX = WS-PX + WS-NX
                 COMPUTE WS-NZ = WS-PZ + WS-NZ
                 CALL "FR-DEC-SHELF-AT" USING WS-NX TW-LOG-Y(WS-K) WS-NZ WS-HIT
                 IF WS-HIT = 1
                     MOVE 1 TO WS-BAD
                 END-IF
                 CALL "FR-DEC-HDIR" USING WS-M WS-NX WS-NZ
                 COMPUTE WS-NX = TW-LOG-X(WS-K) + WS-NX
                 COMPUTE WS-NZ = TW-LOG-Z(WS-K) + WS-NZ
                 CALL "FR-DEC-SHELF-AT" USING WS-NX TW-LOG-Y(WS-K) WS-NZ WS-HIT
                 IF WS-HIT = 1
                     MOVE 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-IF
         IF WS-BAD = 0
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-AGE
             MOVE WS-AGE TO WS-AGE-TEXT
             MOVE SPACES TO WS-PAIRS
             MOVE WS-FACE-N(WS-D + 1) TO WS-FN
             STRING "age=" WS-AGE-TEXT ",facing=" FUNCTION TRIM(WS-FN) DELIMITED BY SIZE INTO WS-PAIRS
             CALL "FR-DEC-STATE" USING WS-KEY WS-PAIRS WS-STATE
             IF WS-STATE > 0
                 CALL "FL-SET-STATE" USING WS-PX TW-LOG-Y(WS-K) WS-PZ WS-STATE WS-FLAGS WS-HIT
             END-IF
             MOVE 1 TO WS-OK
         END-IF
     END-IF
     .
 END PROGRAM FR-DEC-SHELF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-LEAVES.
*> USING state, row, slot: attached_to_leaves (3.3): a shuffled copy of the sorted leaves; for each leaf a direction draw nextInt(size) (p = leaf + d); p inside an exclusion box ends that leaf with no
*> more draws; else nextFloat() strictly below the probability with the cells leaf + d * 1 to leaf + d * required_empty_blocks all air adds the box of radius (xz, y, xz) round p to the exclusion set and
*> sets the provider's state at p.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     MOVE 0 TO TW-NXC
     CALL "FR-DEC-SORTL"
     CALL "FR-DEC-SHUFFLE-L" USING L-STATE TW-NLEAF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         MOVE TW-SHL(WS-I) TO WS-K
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE TD-ND(L-ROW, L-SLOT) WS-DIR
         MOVE TD-DIR(L-ROW, L-SLOT, WS-DIR + 1) TO WS-DIR
         CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-PX = TW-LEAF-X(WS-K) + WS-DX
         COMPUTE WS-PY = TW-LEAF-Y(WS-K) + WS-DY
         COMPUTE WS-PZ = TW-LEAF-Z(WS-K) + WS-DZ
         MOVE 0 TO WS-IN
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TW-NXC OR WS-IN = 1
             IF FUNCTION ABS(WS-PX - TW-XC-X(WS-J)) <= TD-I(L-ROW, L-SLOT, 1)
                 AND FUNCTION ABS(WS-PY - TW-XC-Y(WS-J)) <= TD-I(L-ROW, L-SLOT, 2)
                 AND FUNCTION ABS(WS-PZ - TW-XC-Z(WS-J)) <= TD-I(L-ROW, L-SLOT, 1)
                 MOVE 1 TO WS-IN
             END-IF
         END-PERFORM
         IF WS-IN = 0
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-P
                 MOVE 1 TO WS-ALL
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > TD-I(L-ROW, L-SLOT, 3)
                     COMPUTE WS-QX = TW-LEAF-X(WS-K) + WS-DX * WS-S
                     COMPUTE WS-QY = TW-LEAF-Y(WS-K) + WS-DY * WS-S
                     COMPUTE WS-QZ = TW-LEAF-Z(WS-K) + WS-DZ * WS-S
                     CALL "FR-DEC-AIR" USING WS-QX WS-QY WS-QZ WS-AIR
                     IF WS-AIR = 0
                         MOVE 0 TO WS-ALL
                     END-IF
                 END-PERFORM
                 IF WS-ALL = 1
                     IF TW-NXC < 1024
                         ADD 1 TO TW-NXC
                         MOVE WS-PX TO TW-XC-X(TW-NXC)
                         MOVE WS-PY TO TW-XC-Y(TW-NXC)
                         MOVE WS-PZ TO TW-XC-Z(TW-NXC)
                     END-IF
                     CALL "FR-PROV-STATE" USING L-STATE TD-PV(L-ROW, L-SLOT) WS-PX WS-PY WS-PZ WS-NEW WS-OK
                     IF WS-OK = 1
                         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-OK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-LEAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-HANGER.
*> USING state, x, y, z, tip false state, tip true state: the moss hanger (3.3): while the cell below p is air, nextFloat() below 0.5 ends it, else the non-tip moss goes at p and p moves down; the tip at p.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BY                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-BODY L-TIP.
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1
         COMPUTE WS-BY = L-Y - 1
         CALL "FR-DEC-AIR" USING L-X WS-BY L-Z WS-AIR
         IF WS-AIR = 0
             MOVE 1 TO WS-STOP
         ELSE
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-HALF
                 MOVE 1 TO WS-STOP
             ELSE
                 IF L-BODY > 0
                     CALL "FL-SET-STATE" USING L-X L-Y L-Z L-BODY WS-FLAGS WS-OK
                 END-IF
                 SUBTRACT 1 FROM L-Y
             END-IF
         END-IF
     END-PERFORM
     IF L-TIP > 0
         CALL "FL-SET-STATE" USING L-X L-Y L-Z L-TIP WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM FR-DEC-HANGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-PALE.
*> USING state, row, slot: pale_moss (3.3): a shuffled copy of the logs (no logs ends it), the lowest of it (the first on ties); nextFloat() below the ground probability places the pale_moss_patch
*> feature one above it; for each log in sorted order nextFloat() below the trunk probability with air below the log runs the hanger at the cell below; the leaves likewise with the leaves probability.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:pale_hanging_moss".
 01 WS-PAIRS-BODY          PIC X(160) VALUE "tip=false".
 01 WS-PAIRS-TIP           PIC X(160) VALUE "tip=true".
 01 WS-BODY                BINARY-LONG.
 01 WS-TIP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-PG                  FLOAT-LONG.
 01 WS-PT                  FLOAT-LONG.
 01 WS-PL                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-PL
     MOVE TD-F2(L-ROW, L-SLOT) TO WS-PT
     MOVE TD-F3(L-ROW, L-SLOT) TO WS-PG
     CALL "FR-F32" USING WS-PL
     CALL "FR-F32" USING WS-PT
     CALL "FR-F32" USING WS-PG
     CALL "FR-DEC-SHUFFLE" USING L-STATE TW-NLOG
     IF TW-NLOG = 0
         GOBACK
     END-IF
     MOVE TW-SH(1) TO WS-LOW
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TW-SH(WS-I) TO WS-K
         IF TW-LOG-Y(WS-K) < TW-LOG-Y(WS-LOW)
             MOVE WS-K TO WS-LOW
         END-IF
     END-PERFORM
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F < WS-PG AND TD-FT(L-ROW, L-SLOT) > 0
         MOVE TW-LOG-X(WS-LOW) TO WS-PX
         COMPUTE WS-PY = TW-LOG-Y(WS-LOW) + 1
         MOVE TW-LOG-Z(WS-LOW) TO WS-PZ
         MOVE TD-FT(L-ROW, L-SLOT) TO WS-FT
         CALL "FR-PLACE-FT" USING L-STATE WS-FT WS-PX WS-PY WS-PZ WS-RESULT
     END-IF
     CALL "FR-DEC-STATE" USING WS-KEY WS-PAIRS-BODY WS-BODY
     CALL "FR-DEC-STATE" USING WS-KEY WS-PAIRS-TIP WS-TIP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TW-LS(WS-I) TO WS-K
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         MOVE TW-LOG-X(WS-K) TO WS-PX
         COMPUTE WS-PY = TW-LOG-Y(WS-K) - 1
         MOVE TW-LOG-Z(WS-K) TO WS-PZ
         CALL "FR-DEC-AIR" USING WS-PX WS-PY WS-PZ WS-AIR
         IF WS-F < WS-PT AND WS-AIR = 1
             CALL "FR-DEC-HANGER" USING L-STATE WS-PX WS-PY WS-PZ WS-BODY WS-TIP
         END-IF
     END-PERFORM
     CALL "FR-DEC-SORTL"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         MOVE TW-LFS(WS-I) TO WS-K
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         MOVE TW-LEAF-X(WS-K) TO WS-PX
         COMPUTE WS-PY = TW-LEAF-Y(WS-K) - 1
         MOVE TW-LEAF-Z(WS-K) TO WS-PZ
         CALL "FR-DEC-AIR" USING WS-PX WS-PY WS-PZ WS-AIR
         IF WS-F < WS-PL AND WS-AIR = 1
             CALL "FR-DEC-HANGER" USING L-STATE WS-PX WS-PY WS-PZ WS-BODY WS-TIP
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-PALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DEC-HEART.
*> USING state, row, slot: creaking_heart (3.3): no logs ends it, then nextFloat() at or above the probability; a shuffled copy of the logs; the first log whose six face neighbours are all logs (the
*> tag pool of the tree) becomes creaking_heart (state dormant, natural true) and the rest stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:creaking_heart".
 01 WS-PAIRS               PIC X(160) VALUE "axis=y,creaking_heart_state=dormant,natural=true".
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SLOT.
     IF TW-NLOG = 0
         GOBACK
     END-IF
     MOVE TD-PROB(L-ROW, L-SLOT) TO WS-P
     CALL "FR-F32" USING WS-P
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F >= WS-P
         GOBACK
     END-IF
     CALL "FR-DEC-SHUFFLE" USING L-STATE TW-NLOG
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG OR WS-DONE = 1
         MOVE TW-SH(WS-I) TO WS-K
         MOVE 1 TO WS-ALL
         PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
             CALL "F353-STEP" USING WS-D WS-DX WS-DY WS-DZ
             COMPUTE WS-NX = TW-LOG-X(WS-K) + WS-DX
             COMPUTE WS-NY = TW-LOG-Y(WS-K) + WS-DY
             COMPUTE WS-NZ = TW-LOG-Z(WS-K) + WS-DZ
             CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             MOVE 0 TO WS-HAS
             IF WS-BLOCK > 0
                 CALL "FR-POOL-HAS" USING TW-LOGS-START TW-LOGS-N WS-BLOCK WS-HAS
             END-IF
             IF WS-HAS = 0
                 MOVE 0 TO WS-ALL
             END-IF
         END-PERFORM
         IF WS-ALL = 1
             MOVE 1 TO WS-DONE
             CALL "FR-DEC-STATE" USING WS-KEY WS-PAIRS WS-STATE
             IF WS-STATE > 0
                 CALL "FL-SET-STATE" USING TW-LOG-X(WS-K) TW-LOG-Y(WS-K) TW-LOG-Z(WS-K) WS-STATE WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DEC-HEART.
