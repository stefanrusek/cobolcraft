*> The ghast's float point clamp (lane p49d; docs/protocol/44 part 6 section 9.1, RandomFloatAroundGoal): the chosen point is moved so that the ghast does not float over open void.
*> Entry points:
*>   GHAST-HEIGHT USING dim, x, z (BINARY-LONG column), height out: the MOTION_BLOCKING height of the column: 1 + the y of the highest block that blocks motion or holds a fluid (a full solid
*>     block, water or lava by MS6-BLOCK-KIND), the world's minimum y for a column with none.
*>   GHAST-CLAMP USING dim, mob y, x, y, z of the point (FLOAT-LONG), new y out: when the column's height is below the point's block y and above the world's minimum y, the point's y
*>     becomes mob y - |mob y - point y| (a point above the ghast is mirrored below it); otherwise it stays.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-Y                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-HEIGHT.
     MOVE DM-MIN-Y(L-DIM) TO L-HEIGHT
     MOVE 0 TO WS-DONE
     COMPUTE WS-Y = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     PERFORM UNTIL WS-Y < DM-MIN-Y(L-DIM) OR WS-DONE = 1
         CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-KIND
         IF WS-KIND = 1 OR WS-KIND = 2 OR WS-KIND = 3
             COMPUTE L-HEIGHT = WS-Y + 1
             MOVE 1 TO WS-DONE
         END-IF
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM GHAST-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-CLAMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-BLOCK-Y             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-MOB-Y                FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-NEW-Y                FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-MOB-Y L-X L-Y L-Z L-NEW-Y.
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     COMPUTE WS-BLOCK-Y = FUNCTION INTEGER(L-Y)
     CALL "GHAST-HEIGHT" USING L-DIM WS-X WS-Z WS-HEIGHT
     MOVE L-Y TO L-NEW-Y
     IF WS-HEIGHT < WS-BLOCK-Y AND WS-HEIGHT > DM-MIN-Y(L-DIM)
         COMPUTE L-NEW-Y = L-MOB-Y - FUNCTION ABS(L-MOB-Y - L-Y)
     END-IF
     GOBACK.
 END PROGRAM GHAST-CLAMP.
