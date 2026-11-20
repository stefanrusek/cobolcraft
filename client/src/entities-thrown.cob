*> Thrown items, the firework rocket and the ominous item spawner in the ground item mesh (docs/protocol/34-entity-models-9-non-living-entities.md sections 7 and 9.3).
*>   ENTITY-THROWN-EMIT USING CLIENT-STATE, replica row, eye (3 FLOAT-LONG): the flat model of the item the entity carries (Set Entity Data entry 8) as one quad facing the camera
*>     (the camera yaw only, as the orb's quad): the corners of EF9-THROWN-QUAD (scale of the type, a firework shot at an angle turned, entry 10), at the entity's position, the cell's
*>     light with the block light 15 for a full bright type (EF9-THROWN-LIGHT);
*>   ENTITY-SPAWNER-EMIT the same for an ominous_item_spawner (9.3): renderedAmount copies of EF9-CLUSTER (flat model, zSize 0.03125) under scale age / 50 (age <= 50) and the Y rotation
*>     wrapDegrees(age x 40) degrees, full bright, no bob; both sides of each copy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-THROWN-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-Q.
    05 WS-QV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-KEY                 PIC X(24).
 01 WS-SCALE               FLOAT-LONG.
 01 WS-FULL                FLOAT-LONG.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X             FLOAT-SHORT.
       10 WS-C-Y             FLOAT-SHORT.
       10 WS-C-Z             FLOAT-SHORT.
       10 WS-C-U             FLOAT-SHORT.
       10 WS-C-V             FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     IF EN-STACK-COUNT(L-ROW) <= 0 OR RL-GI-COUNT + 6 > CL-MAX-GI-VERTICES
         GOBACK
     END-IF
     MOVE EN-KEY(L-ROW) TO WS-KEY
     MOVE 0 TO WS-ANGLE
     IF WS-KEY = "firework_rocket"
         MOVE 1 TO WS-OV(1)
         MOVE 1 TO WS-OV(2)
         MOVE 0 TO WS-OV(3)
         MOVE EN-X1(L-ROW) TO WS-ANGLE
     ELSE
         CALL "EF9-THROWN" USING WS-KEY WS-O
     END-IF
     IF WS-OV(1) = 0
         GOBACK
     END-IF
     MOVE WS-OV(2) TO WS-SCALE
     MOVE WS-OV(3) TO WS-FULL
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE EN-STACK-ITEM(L-ROW) WS-SPRITE
     MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-BLOCK TO WS-IV(1)
     MOVE WS-FULL TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-I WS-O
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-OV(1)) / 15
     MOVE WS-SCALE TO WS-IV(1)
     MOVE WS-ANGLE TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-I WS-Q
*>   The camera's right and the direction toward the camera (yaw only): right (-cos, -sin), toward the camera (sin, -cos).
     COMPUTE WS-RX = - FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-RZ = - FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-BX = FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-BZ = - FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-B = WS-K * 3 - 2
         COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-QV(WS-B) * WS-RX + WS-QV(WS-B + 2) * WS-BX
         COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-QV(WS-B + 1)
         COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-QV(WS-B) * WS-RZ + WS-QV(WS-B + 2) * WS-BZ
         MOVE 0 TO WS-U16
         IF WS-K = 2 OR WS-K = 3
             MOVE 16 TO WS-U16
         END-IF
         MOVE 0 TO WS-V16
         IF WS-K >= 3
             MOVE 16 TO WS-V16
         END-IF
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-K) WS-C-V(WS-K)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-ORD(WS-K) TO WS-N
         ADD 1 TO RL-GI-COUNT
         MOVE WS-C-X(WS-N) TO RL-GI-X(RL-GI-COUNT)
         MOVE WS-C-Y(WS-N) TO RL-GI-Y(RL-GI-COUNT)
         MOVE WS-C-Z(WS-N) TO RL-GI-Z(RL-GI-COUNT)
         MOVE WS-C-U(WS-N) TO RL-GI-U(RL-GI-COUNT)
         MOVE WS-C-V(WS-N) TO RL-GI-V(RL-GI-COUNT)
         MOVE WS-LIGHT TO RL-GI-B(RL-GI-COUNT)
         MOVE 1 TO RL-GI-A(RL-GI-COUNT)
         MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
         MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-THROWN-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SPAWNER-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-CL.
    05 WS-CLV              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-OPS.
    05 WS-OP               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-SPIN                FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-COPIES              BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X             FLOAT-SHORT.
       10 WS-C-Y             FLOAT-SHORT.
       10 WS-C-Z             FLOAT-SHORT.
       10 WS-C-U             FLOAT-SHORT.
       10 WS-C-V             FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(12) VALUE "123134132143".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 12 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     IF EN-STACK-COUNT(L-ROW) <= 0
         GOBACK
     END-IF
     COMPUTE WS-AGE = CL-NOW-MS / 50
     MOVE WS-AGE TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-I WS-OPS
     MOVE 1 TO WS-SCALE
     MOVE 0 TO WS-SPIN
     MOVE WS-OP(1) TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         COMPUTE WS-B = WS-J * 4 - 2
         IF WS-OP(WS-B) = 2
             MOVE WS-OP(WS-B + 1) TO WS-SCALE
         ELSE
             MOVE WS-OP(WS-B + 1) TO WS-SPIN
         END-IF
     END-PERFORM
     COMPUTE WS-SIN = FUNCTION SIN(WS-SPIN * FUNCTION PI / 180)
     COMPUTE WS-COS = FUNCTION COS(WS-SPIN * FUNCTION PI / 180)
     MOVE EN-STACK-COUNT(L-ROW) TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-I WS-O
     MOVE WS-OV(1) TO WS-COPIES
     IF RL-GI-COUNT + 12 * WS-COPIES > CL-MAX-GI-VERTICES
         GOBACK
     END-IF
     MOVE WS-COPIES TO WS-CLV(1)
     MOVE WS-COPIES TO WS-IV(1)
     MOVE EN-STACK-ITEM(L-ROW) TO WS-IV(2)
     MOVE 0.03125 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-I WS-CL
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE EN-STACK-ITEM(L-ROW) WS-SPRITE
     MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-COPIES
         COMPUTE WS-B = WS-J * 3 + 2
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE -0.25 TO WS-LX
             MOVE 0 TO WS-U16
             IF WS-K = 2 OR WS-K = 3
                 MOVE 0.25 TO WS-LX
                 MOVE 16 TO WS-U16
             END-IF
             MOVE 0.375 TO WS-LY
             MOVE 0 TO WS-V16
             IF WS-K >= 3
                 MOVE -0.125 TO WS-LY
                 MOVE 16 TO WS-V16
             END-IF
             COMPUTE WS-LX = WS-LX + WS-CLV(WS-B)
             COMPUTE WS-LY = WS-LY + WS-CLV(WS-B + 1)
             MOVE WS-CLV(WS-B + 2) TO WS-LZ
             COMPUTE WS-SX = (WS-LX * WS-COS + WS-LZ * WS-SIN) * WS-SCALE
             COMPUTE WS-SZ = (WS-LZ * WS-COS - WS-LX * WS-SIN) * WS-SCALE
             COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-SX
             COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-LY * WS-SCALE
             COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-SZ
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-K) WS-C-V(WS-K)
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
             MOVE WS-ORD(WS-K) TO WS-N
             ADD 1 TO RL-GI-COUNT
             MOVE WS-C-X(WS-N) TO RL-GI-X(RL-GI-COUNT)
             MOVE WS-C-Y(WS-N) TO RL-GI-Y(RL-GI-COUNT)
             MOVE WS-C-Z(WS-N) TO RL-GI-Z(RL-GI-COUNT)
             MOVE WS-C-U(WS-N) TO RL-GI-U(RL-GI-COUNT)
             MOVE WS-C-V(WS-N) TO RL-GI-V(RL-GI-COUNT)
             MOVE 1 TO RL-GI-B(RL-GI-COUNT)
             MOVE 1 TO RL-GI-A(RL-GI-COUNT)
             MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
             MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SPAWNER-EMIT.
