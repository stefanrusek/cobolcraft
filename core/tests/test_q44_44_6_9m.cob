*> Implementation test (lane 002-lane-p49s, T38500; docs/protocol/44-residual-mob-questions-6-nether.md section 9.1 GhastMoveControl and RandomFloatAroundGoal): the gain is
*> normalize(delta) x 0.1 from rest (no start velocity); floatDuration falls first and the control acts only when it was <= 0 before the fall (then + nextInt(5) + 2, so 1 to 5);
*> canReach sweeps the 4 x 4 x 4 box along the way, a cell the current box already intersects is passable, fluids are ignored; the wanted point over an open column is
*> mirrored below the ghast (x, mobY - |mobY - pointY|, z) when the column's height is below the point and above the minimum Y.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-9M.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-C.
    05 WS-CV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-D.
    05 WS-DV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MIN.
    05 WS-MINV             FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MAX.
    05 WS-MAXV             FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 2 TO BW-DIFFICULTY

*>   The ghast hangs 10 blocks over the floor, feet on a whole Y, centre on a half block; the air around it is cleared.
     COMPUTE WS-GX = FUNCTION INTEGER(WS-X) + 0.5
     COMPUTE WS-GY = FUNCTION INTEGER(WS-Y) + 10
     COMPUTE WS-GZ = FUNCTION INTEGER(WS-Z) + 0.5
     PERFORM VARYING WS-I FROM -4 BY 1 UNTIL WS-I > 14
         PERFORM VARYING WS-J FROM -3 BY 1 UNTIL WS-J > 8
             PERFORM VARYING WS-K FROM -6 BY 1 UNTIL WS-K > 6
                 COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + WS-I
                 COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + WS-J
                 COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ) + WS-K
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>   From rest the gain is normalize(delta) x 0.1: a target 6 east and 8 up gives (0.06, 0.08), moved and dragged by 0.91.
     PERFORM SPAWN-GHAST
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX + 6
     COMPUTE EN-PH-TY(WS-ROW) = WS-GY + 8
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     MOVE 0 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: from rest the gain is normalize(delta) x 0.1 (vx 0.0546)" TO WS-CASE
     MOVE 546 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-6 9.1: from rest the gain is normalize(delta) x 0.1 (vy 0.0728)" TO WS-CASE
     MOVE 728 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-6 9.1: floatDuration is 1 to 5 after the first action" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-PH-SCAN(WS-ROW) >= 1 AND EN-PH-SCAN(WS-ROW) <= 5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   floatDuration 1: it falls to 0 and the control does not act (the old value was above 0); the next tick acts.
     PERFORM SPAWN-GHAST
     PERFORM EAST-TARGET
     MOVE 1 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: floatDuration 1 falls to 0 without a gain" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-6 9.1: floatDuration 1 falls to 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-PH-SCAN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: the next tick acts (vx 0.091)" TO WS-CASE
     MOVE 910 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   A cell inside the sweep of the box but off the centre line blocks the way: the cell 2 to the side, its z range overlaps the box's.
     PERFORM SPAWN-GHAST
     PERFORM EAST-TARGET
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 5
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 3
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ) + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: a cell off the centre line within the box's sweep blocks the way" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The same cell one block further out misses the box.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ) + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     PERFORM SPAWN-GHAST
     PERFORM EAST-TARGET
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: a cell outside the box's sweep leaves the way free" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR

*>   A cell the current box already intersects is passable.
     PERFORM SPAWN-GHAST
     PERFORM EAST-TARGET
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 1
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 1
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: a cell the current box intersects does not block" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR

*>   Fluids are ignored: a water cell on the way does not block it.
     PERFORM SPAWN-GHAST
     PERFORM EAST-TARGET
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 5
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 1
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-WATER
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: water on the way does not block" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR

*>   Westward and downward ways (negative components) are swept too.
     PERFORM SPAWN-GHAST
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX - 10
     COMPUTE EN-PH-TY(WS-ROW) = WS-GY - 6
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     MOVE 0 TO EN-PH-SCAN(WS-ROW)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) - 6
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) - 3
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 44-6 9.1: a cell on a west and down way blocks it" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR

*>   The segment against an inflated box: along +x into a box ahead, along -x past a box that is off the line, and a way that grazes a face.
     MOVE 0 TO WS-CV(1) WS-CV(2) WS-CV(3)
     MOVE 10 TO WS-DV(1)
     MOVE 0 TO WS-DV(2) WS-DV(3)
     MOVE 4 TO WS-MINV(1)
     MOVE -1 TO WS-MINV(2) WS-MINV(3)
     MOVE 6 TO WS-MAXV(1)
     MOVE 1 TO WS-MAXV(2) WS-MAXV(3)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: the segment hits a box ahead" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -10 TO WS-DV(1)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: the segment away from the box misses it" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 10 TO WS-DV(1)
     MOVE 3 TO WS-CV(2)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: a parallel segment outside the slab misses" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-CV(2)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: a segment on the face plane only touches" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-CV(2)
     MOVE 3 TO WS-DV(1)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: a segment that stops before the box misses" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-DV(1)
     CALL "GHAST-SEG-HITS" USING WS-C WS-D WS-MIN WS-MAX WS-OK
     MOVE "acceptance US15 44-6 9.1: no movement hits nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-OK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The void clamp. The mob is 10 over the floor; the floor's column top is the Y of the floor + 1.
     PERFORM SPAWN-GHAST
     MOVE WS-GX TO WS-PX
     MOVE WS-GZ TO WS-PZ
     COMPUTE WS-PY = WS-GY + 5
     CALL "GHAST-CLAMP" USING WS-ROW WS-PX WS-PY WS-PZ
     MOVE "acceptance US15 44-6 9.1: a point over an open column is mirrored below the ghast" TO WS-CASE
     COMPUTE WS-EXP = FUNCTION INTEGER(WS-GY) - 5
     COMPUTE WS-OBS = FUNCTION INTEGER(WS-PY)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-PY = WS-GY - 3
     CALL "GHAST-CLAMP" USING WS-ROW WS-PX WS-PY WS-PZ
     MOVE "acceptance US15 44-6 9.1: a point below the ghast over an open column stays" TO WS-CASE
     COMPUTE WS-EXP = FUNCTION INTEGER(WS-GY) - 3
     COMPUTE WS-OBS = FUNCTION INTEGER(WS-PY)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-PY = WS-Y - 5
     CALL "GHAST-CLAMP" USING WS-ROW WS-PX WS-PY WS-PZ
     MOVE "acceptance US15 44-6 9.1: a point under the column's height stays" TO WS-CASE
     COMPUTE WS-EXP = FUNCTION INTEGER(WS-Y) - 5
     COMPUTE WS-OBS = FUNCTION INTEGER(WS-PY)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A column void throughout (nothing above the minimum Y) is left alone.
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 30
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     COMPUTE WS-K = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM)
     PERFORM VARYING WS-FY FROM DM-MIN-Y(WS-DIM) BY 1 UNTIL WS-FY >= WS-K
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     END-PERFORM
     COMPUTE WS-PX = WS-FX + 0.5
     COMPUTE WS-PY = WS-GY + 5
     CALL "GHAST-CLAMP" USING WS-ROW WS-PX WS-PY WS-PZ
     MOVE "acceptance US15 44-6 9.1: an empty column is not clamped" TO WS-CASE
     COMPUTE WS-EXP = FUNCTION INTEGER(WS-GY) + 5
     COMPUTE WS-OBS = FUNCTION INTEGER(WS-PY)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     STOP RUN.
 SPAWN-GHAST.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW.
 EAST-TARGET.
*>   A wanted point 10 blocks east at the ghast's height, floatDuration 0 (acts on the first tick).
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX + 10
     MOVE WS-GY TO EN-PH-TY(WS-ROW)
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     MOVE 0 TO EN-PH-SCAN(WS-ROW).
 END PROGRAM TEST-Q44-44-6-9M.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
