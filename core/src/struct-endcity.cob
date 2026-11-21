*> The end city's piece layout (docs/protocol/36-structures-8-nether-and-end.md sections 8.2, 9.2, 10 and the vectors of 12; state in STRUCTEC.cpy). The template engine, the data markers and the
*> loot (9.3, 9.4, 11) are not here.
*> Entry points:
*>   ENDCITY-START USING seed (BINARY-DOUBLE UNSIGNED), chunk x, chunk z, lowest y (the caller's getLowestYIn5by5Box), valid out: the start (8.2): setLargeFeatureSeed, the rotation draw, the y < 60 rule and
*>     startHouseTower at (chunk x * 16 + 7, lowest y, chunk z * 16 + 7); the list is EC-PIECE.
*>   ENDCITY-HOUSE USING x, y, z, rotation: startHouseTower (10.2) with the random SP-RNG.
*>   ENDCITY-CORNER USING rotation, sx out, sz out: the corner offsets of 8.2 step 4.
*>   ENDCITY-SIZE USING name, sx out, sy out, sz out: the template sizes of 11.1.
*>   ENDCITY-ADD USING name, parent row (0 none), x, y, z (an offset, or the position without a parent), rotation, overwrite, row out: addPiece (9.2).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-SIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(32) VALUE "base_floor          010004010".
    05 FILLER PIC X(32) VALUE "base_roof           012002012".
    05 FILLER PIC X(32) VALUE "second_floor_1      012008012".
    05 FILLER PIC X(32) VALUE "second_floor_2      012008012".
    05 FILLER PIC X(32) VALUE "second_roof         014002014".
    05 FILLER PIC X(32) VALUE "third_floor_1       014008014".
    05 FILLER PIC X(32) VALUE "third_floor_2       014008014".
    05 FILLER PIC X(32) VALUE "third_roof          016002016".
    05 FILLER PIC X(32) VALUE "tower_base          007007007".
    05 FILLER PIC X(32) VALUE "tower_piece         007004007".
    05 FILLER PIC X(32) VALUE "tower_top           009005009".
    05 FILLER PIC X(32) VALUE "fat_tower_base      013004013".
    05 FILLER PIC X(32) VALUE "fat_tower_middle    013008013".
    05 FILLER PIC X(32) VALUE "fat_tower_top       017006017".
    05 FILLER PIC X(32) VALUE "bridge_end          005006002".
    05 FILLER PIC X(32) VALUE "bridge_piece        005006004".
    05 FILLER PIC X(32) VALUE "bridge_steep_stairs 005007004".
    05 FILLER PIC X(32) VALUE "bridge_gentle_stairs005007008".
    05 FILLER PIC X(32) VALUE "ship                013024029".
 01 WS-TAB REDEFINES WS-TABLE.
    05 WS-T OCCURS 19 TIMES.
       10 WS-T-NAME        PIC X(20).
       10 WS-T-X           PIC 999.
       10 WS-T-Y           PIC 999.
       10 WS-T-Z           PIC 999.
       10 FILLER           PIC X(3).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-SX L-SY L-SZ.
     MOVE 0 TO L-SX L-SY L-SZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         IF WS-T-NAME(WS-I) = L-NAME
             MOVE WS-T-X(WS-I) TO L-SX
             MOVE WS-T-Y(WS-I) TO L-SY
             MOVE WS-T-Z(WS-I) TO L-SZ
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENDCITY-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-TURN.
*> USING rotation, x, z (in and out): StructureTemplate.transform of an offset about the origin (9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-X L-Z.
     MOVE L-X TO WS-X
     EVALUATE L-ROT
         WHEN 1
             COMPUTE L-X = 0 - L-Z
             MOVE WS-X TO L-Z
         WHEN 2
             COMPUTE L-X = 0 - WS-X
             COMPUTE L-Z = 0 - L-Z
         WHEN 3
             MOVE L-Z TO L-X
             COMPUTE L-Z = 0 - WS-X
     END-EVALUATE
     GOBACK.
 END PROGRAM ENDCITY-TURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-PARENT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-PARENT L-X L-Y L-Z L-ROT L-OW L-ROW.
     ADD 1 TO EC-COUNT
     MOVE EC-COUNT TO L-ROW
     MOVE L-NAME TO EP-NAME(L-ROW)
     MOVE L-X TO WS-OX
     MOVE L-Z TO WS-OZ
     IF L-PARENT = 0
         MOVE L-X TO EP-X(L-ROW)
         MOVE L-Y TO EP-Y(L-ROW)
         MOVE L-Z TO EP-Z(L-ROW)
     ELSE
         CALL "ENDCITY-TURN" USING EP-ROT(L-PARENT) WS-OX WS-OZ
         COMPUTE EP-X(L-ROW) = EP-X(L-PARENT) + WS-OX
         COMPUTE EP-Y(L-ROW) = EP-Y(L-PARENT) + L-Y
         COMPUTE EP-Z(L-ROW) = EP-Z(L-PARENT) + WS-OZ
     END-IF
     MOVE L-ROT TO EP-ROT(L-ROW)
     MOVE L-OW TO EP-OW(L-ROW)
     MOVE 0 TO EP-GD(L-ROW)
     CALL "ENDCITY-SIZE" USING L-NAME WS-SX WS-SY WS-SZ
     COMPUTE WS-SX = WS-SX - 1
     COMPUTE WS-SZ = WS-SZ - 1
     MOVE WS-SX TO WS-CX
     MOVE WS-SZ TO WS-CZ
     CALL "ENDCITY-TURN" USING L-ROT WS-CX WS-CZ
     COMPUTE EP-X0(L-ROW) = EP-X(L-ROW) + FUNCTION MIN(0, WS-CX)
     COMPUTE EP-X1(L-ROW) = EP-X(L-ROW) + FUNCTION MAX(0, WS-CX)
     COMPUTE EP-Z0(L-ROW) = EP-Z(L-ROW) + FUNCTION MIN(0, WS-CZ)
     COMPUTE EP-Z1(L-ROW) = EP-Z(L-ROW) + FUNCTION MAX(0, WS-CZ)
     MOVE EP-Y(L-ROW) TO EP-Y0(L-ROW)
     COMPUTE EP-Y1(L-ROW) = EP-Y(L-ROW) + WS-SY - 1
     GOBACK.
 END PROGRAM ENDCITY-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-RECURSE IS RECURSIVE.
*> USING generator (1 house tower, 2 tower, 3 tower bridge, 4 fat tower), depth, parent row, offset x, y, z, first row of the list, result out: recursiveChildren (10.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-BITS                BINARY-LONG VALUE 32.
 LOCAL-STORAGE SECTION.
 01 LS-GEN                 BINARY-LONG.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-PARENT              BINARY-LONG.
 01 LS-LIST                BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-ID                  BINARY-DOUBLE.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-REJECT              BINARY-LONG.
 01 LS-HIT                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-GEN                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-GEN L-DEPTH L-PARENT L-X L-Y L-Z L-LIST L-RESULT.
     MOVE L-GEN TO LS-GEN
     MOVE L-DEPTH TO LS-DEPTH
     MOVE L-PARENT TO LS-PARENT
     MOVE L-LIST TO LS-LIST
     MOVE 0 TO L-RESULT
     IF LS-DEPTH > 8
         GOBACK
     END-IF
     COMPUTE LS-START = EC-COUNT + 1
     EVALUATE LS-GEN
         WHEN 1
             CALL "ENDCITY-HOUSE-GEN" USING LS-DEPTH LS-PARENT L-X L-Y L-Z LS-START LS-OK
         WHEN 2
             CALL "ENDCITY-TOWER-GEN" USING LS-DEPTH LS-PARENT LS-START LS-OK
         WHEN 3
             CALL "ENDCITY-BRIDGE-GEN" USING LS-DEPTH LS-PARENT LS-START LS-OK
         WHEN OTHER
             CALL "ENDCITY-FAT-GEN" USING LS-DEPTH LS-PARENT LS-START LS-OK
     END-EVALUATE
     IF LS-OK = 0
         COMPUTE EC-COUNT = LS-START - 1
         GOBACK
     END-IF
*>   the group id, then the first collision of each piece with the list
     CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-ID
     MOVE 0 TO LS-REJECT
     PERFORM VARYING LS-I FROM LS-START BY 1 UNTIL LS-I > EC-COUNT OR LS-REJECT = 1
         COMPUTE EP-GD(LS-I) = LS-ID
         MOVE 0 TO LS-HIT
         PERFORM VARYING LS-J FROM LS-LIST BY 1 UNTIL LS-J >= LS-START OR LS-HIT > 0
             IF EP-X0(LS-I) <= EP-X1(LS-J) AND EP-X1(LS-I) >= EP-X0(LS-J) AND EP-Y0(LS-I) <= EP-Y1(LS-J)
                 AND EP-Y1(LS-I) >= EP-Y0(LS-J) AND EP-Z0(LS-I) <= EP-Z1(LS-J) AND EP-Z1(LS-I) >= EP-Z0(LS-J)
                 MOVE LS-J TO LS-HIT
             END-IF
         END-PERFORM
         IF LS-HIT > 0
             IF EP-GD(LS-HIT) NOT = EP-GD(LS-PARENT)
                 MOVE 1 TO LS-REJECT
             END-IF
         END-IF
     END-PERFORM
     IF LS-REJECT = 1
         COMPUTE EC-COUNT = LS-START - 1
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM ENDCITY-RECURSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-HOUSE-GEN IS RECURSIVE.
*> USING depth, parent row, offset x, y, z, group start, result out: HOUSE_TOWER_GENERATOR.generate (10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-PARENT              BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-ROT                 BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-CUR                 BINARY-LONG.
 01 LS-NAME                PIC X(24).
 01 LS-PX                  BINARY-LONG.
 01 LS-PY                  BINARY-LONG.
 01 LS-PZ                  BINARY-LONG.
 01 LS-ONE                 BINARY-LONG.
 01 LS-OW                  BINARY-LONG.
 01 LS-GEN                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-NONE-X              BINARY-LONG.
 01 LS-NONE-Y              BINARY-LONG.
 01 LS-NONE-Z              BINARY-LONG.
 01 LS-RES                 BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEPTH                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-PARENT L-X L-Y L-Z L-START L-RESULT.
     MOVE L-DEPTH TO LS-DEPTH
     MOVE L-PARENT TO LS-PARENT
     MOVE L-START TO LS-START
     MOVE EP-ROT(LS-PARENT) TO LS-ROT
     MOVE 1 TO L-RESULT
     MOVE 0 TO LS-NONE-X LS-NONE-Y LS-NONE-Z
     MOVE "base_floor" TO LS-NAME
     MOVE 1 TO LS-OW
     CALL "ENDCITY-ADD" USING LS-NAME LS-PARENT L-X L-Y L-Z LS-ROT LS-OW LS-CUR
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE LS-K
     MOVE -1 TO LS-PX
     MOVE -1 TO LS-PZ
     EVALUATE LS-K
         WHEN 0
             MOVE "base_roof" TO LS-NAME
             MOVE 4 TO LS-PY
             MOVE 1 TO LS-OW
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-ROW
         WHEN 1
             MOVE "second_floor_2" TO LS-NAME
             MOVE 0 TO LS-PY
             MOVE 0 TO LS-OW
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             MOVE "second_roof" TO LS-NAME
             MOVE 8 TO LS-PY
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             MOVE 2 TO LS-GEN
             COMPUTE LS-NEXT = LS-DEPTH + 1
             CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-CUR LS-NONE-X LS-NONE-Y LS-NONE-Z LS-START LS-RES
         WHEN OTHER
             MOVE "second_floor_2" TO LS-NAME
             MOVE 0 TO LS-PY
             MOVE 0 TO LS-OW
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             MOVE "third_floor_2" TO LS-NAME
             MOVE 4 TO LS-PY
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             MOVE "third_roof" TO LS-NAME
             MOVE 8 TO LS-PY
             MOVE 1 TO LS-OW
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             MOVE 2 TO LS-GEN
             COMPUTE LS-NEXT = LS-DEPTH + 1
             CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-CUR LS-NONE-X LS-NONE-Y LS-NONE-Z LS-START LS-RES
     END-EVALUATE
     GOBACK.
 END PROGRAM ENDCITY-HOUSE-GEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-TOWER-GEN IS RECURSIVE.
*> USING depth, parent row, group start, result out: TOWER_GENERATOR.generate (10.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-BITS                BINARY-LONG VALUE 1.
 01 WS-BR.
    05 FILLER PIC X(11) VALUE "0+001-1+000".
    05 FILLER PIC X(11) VALUE "1+006-1+001".
    05 FILLER PIC X(11) VALUE "3+000-1+005".
    05 FILLER PIC X(11) VALUE "2+005-1+006".
 01 WS-BRT REDEFINES WS-BR.
    05 WS-B OCCURS 4 TIMES.
       10 WS-B-ROT         PIC 9.
       10 WS-B-X           PIC S999 SIGN LEADING SEPARATE.
       10 WS-B-Y           PIC S9 SIGN LEADING SEPARATE.
       10 WS-B-Z           PIC S999 SIGN LEADING SEPARATE.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-PARENT              BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-ROT                 BINARY-LONG.
 01 LS-CUR                 BINARY-LONG.
 01 LS-BP                  BINARY-LONG.
 01 LS-NAME                PIC X(24).
 01 LS-PX                  BINARY-LONG.
 01 LS-PY                  BINARY-LONG.
 01 LS-PZ                  BINARY-LONG.
 01 LS-OW                  BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-BOOL                BINARY-DOUBLE.
 01 LS-GEN                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-NONE-X              BINARY-LONG.
 01 LS-NONE-Y              BINARY-LONG.
 01 LS-NONE-Z              BINARY-LONG.
 01 LS-RES                 BINARY-LONG.
 01 LS-BROT                BINARY-LONG.
 01 LS-LAST                BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEPTH                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-PARENT L-START L-RESULT.
     MOVE L-DEPTH TO LS-DEPTH
     MOVE L-PARENT TO LS-PARENT
     MOVE L-START TO LS-START
     MOVE EP-ROT(LS-PARENT) TO LS-ROT
     MOVE 1 TO L-RESULT
     MOVE 0 TO LS-NONE-X LS-NONE-Y LS-NONE-Z
     MOVE 1 TO LS-OW
     MOVE "tower_base" TO LS-NAME
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-TWO LS-PX
     ADD 3 TO LS-PX
     MOVE -3 TO LS-PY
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-TWO LS-PZ
     ADD 3 TO LS-PZ
     CALL "ENDCITY-ADD" USING LS-NAME LS-PARENT LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-CUR
     MOVE "tower_piece" TO LS-NAME
     MOVE 0 TO LS-PX LS-PZ
     MOVE 7 TO LS-PY
     CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
     MOVE LS-NEW TO LS-CUR
     MOVE 0 TO LS-BP
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE LS-R
     IF LS-R = 0
         MOVE LS-CUR TO LS-BP
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE LS-N
     ADD 1 TO LS-N
     MOVE 4 TO LS-PY
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= LS-N
         CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
         MOVE LS-NEW TO LS-CUR
         IF LS-I < LS-N - 1
             CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-BOOL
             IF LS-BOOL NOT = 0
                 MOVE LS-CUR TO LS-BP
             END-IF
         END-IF
     END-PERFORM
     MOVE LS-CUR TO LS-LAST
     IF LS-BP > 0
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
             CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-BOOL
             IF LS-BOOL NOT = 0
                 MOVE "bridge_end" TO LS-NAME
                 COMPUTE LS-BROT = FUNCTION MOD(LS-ROT + WS-B-ROT(LS-I), 4)
                 MOVE WS-B-X(LS-I) TO LS-PX
                 MOVE WS-B-Y(LS-I) TO LS-PY
                 MOVE WS-B-Z(LS-I) TO LS-PZ
                 CALL "ENDCITY-ADD" USING LS-NAME LS-BP LS-PX LS-PY LS-PZ LS-BROT LS-OW LS-CUR
                 MOVE 3 TO LS-GEN
                 COMPUTE LS-NEXT = LS-DEPTH + 1
                 CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-CUR LS-NONE-X LS-NONE-Y LS-NONE-Z LS-START LS-RES
             END-IF
         END-PERFORM
         MOVE "tower_top" TO LS-NAME
         MOVE -1 TO LS-PX LS-PZ
         MOVE 4 TO LS-PY
         CALL "ENDCITY-ADD" USING LS-NAME LS-LAST LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-CUR
         GOBACK
     END-IF
     IF LS-DEPTH = 7
         MOVE "tower_top" TO LS-NAME
         MOVE -1 TO LS-PX LS-PZ
         MOVE 4 TO LS-PY
         CALL "ENDCITY-ADD" USING LS-NAME LS-LAST LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-CUR
         GOBACK
     END-IF
     MOVE 4 TO LS-GEN
     COMPUTE LS-NEXT = LS-DEPTH + 1
     CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-LAST LS-NONE-X LS-NONE-Y LS-NONE-Z LS-START LS-RES
     MOVE LS-RES TO L-RESULT
     GOBACK.
 END PROGRAM ENDCITY-TOWER-GEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-BRIDGE-GEN IS RECURSIVE.
*> USING depth, parent row (a bridge_end), group start, result out: TOWER_BRIDGE_GENERATOR.generate (10.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-BITS                BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-PARENT              BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-ROT                 BINARY-LONG.
 01 LS-P                   BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NAME                PIC X(24).
 01 LS-PX                  BINARY-LONG.
 01 LS-PY                  BINARY-LONG.
 01 LS-PZ                  BINARY-LONG.
 01 LS-OW                  BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-BOOL                BINARY-DOUBLE.
 01 LS-BOUND               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-GEN                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-RES                 BINARY-LONG.
 01 LS-HX                  BINARY-LONG.
 01 LS-HY                  BINARY-LONG.
 01 LS-HZ                  BINARY-LONG.
 01 LS-SHIP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEPTH                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-PARENT L-START L-RESULT.
     MOVE L-DEPTH TO LS-DEPTH
     MOVE L-PARENT TO LS-PARENT
     MOVE L-START TO LS-START
     MOVE EP-ROT(LS-PARENT) TO LS-ROT
     MOVE 1 TO L-RESULT
     MOVE 1 TO LS-OW
     MOVE 0 TO LS-Y
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-FOUR LS-N
     ADD 1 TO LS-N
     MOVE "bridge_piece" TO LS-NAME
     MOVE 0 TO LS-PX LS-PZ
     MOVE 0 TO LS-PY
     MOVE -4 TO LS-PZ
     CALL "ENDCITY-ADD" USING LS-NAME LS-PARENT LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-P
     MOVE -1 TO EP-GD(LS-P)
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
         CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-BOOL
         MOVE LS-Y TO LS-PY
         IF LS-BOOL NOT = 0
             MOVE "bridge_piece" TO LS-NAME
             MOVE -4 TO LS-PZ
             CALL "ENDCITY-ADD" USING LS-NAME LS-P LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-P
             MOVE 0 TO LS-Y
         ELSE
             CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-BOOL
             IF LS-BOOL NOT = 0
                 MOVE "bridge_steep_stairs" TO LS-NAME
                 MOVE -4 TO LS-PZ
             ELSE
                 MOVE "bridge_gentle_stairs" TO LS-NAME
                 MOVE -8 TO LS-PZ
             END-IF
             CALL "ENDCITY-ADD" USING LS-NAME LS-P LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-P
             MOVE 4 TO LS-Y
         END-IF
     END-PERFORM
*>   one ship per city, else a house tower at the end of the bridge
     MOVE 0 TO LS-SHIP
     IF EC-SHIP = 0
         COMPUTE LS-BOUND = 10 - LS-DEPTH
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
         IF LS-DRAW = 0
             MOVE 1 TO LS-SHIP
         END-IF
     END-IF
     IF LS-SHIP = 1
         MOVE 1 TO EC-SHIP
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-EIGHT LS-PX
         COMPUTE LS-PX = LS-PX - 8
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-TEN LS-PZ
         COMPUTE LS-PZ = LS-PZ - 70
         MOVE "ship" TO LS-NAME
         MOVE LS-Y TO LS-PY
         CALL "ENDCITY-ADD" USING LS-NAME LS-P LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
     ELSE
         MOVE 1 TO LS-GEN
         COMPUTE LS-NEXT = LS-DEPTH + 1
         MOVE -3 TO LS-HX
         COMPUTE LS-HY = LS-Y + 1
         MOVE -11 TO LS-HZ
         CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-P LS-HX LS-HY LS-HZ LS-START LS-RES
         IF LS-RES = 0
             MOVE 0 TO L-RESULT
             GOBACK
         END-IF
     END-IF
     MOVE "bridge_end" TO LS-NAME
     MOVE 4 TO LS-PX
     MOVE LS-Y TO LS-PY
     MOVE 0 TO LS-PZ
     COMPUTE LS-ROT = FUNCTION MOD(LS-ROT + 2, 4)
     CALL "ENDCITY-ADD" USING LS-NAME LS-P LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
     MOVE -1 TO EP-GD(LS-NEW)
     GOBACK.
 END PROGRAM ENDCITY-BRIDGE-GEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-FAT-GEN IS RECURSIVE.
*> USING depth, parent row, group start, result out: FAT_TOWER_GENERATOR.generate (10.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-BITS                BINARY-LONG VALUE 1.
 01 WS-BR.
    05 FILLER PIC X(11) VALUE "0+004-1+000".
    05 FILLER PIC X(11) VALUE "1+012-1+004".
    05 FILLER PIC X(11) VALUE "3+000-1+008".
    05 FILLER PIC X(11) VALUE "2+008-1+012".
 01 WS-BRT REDEFINES WS-BR.
    05 WS-B OCCURS 4 TIMES.
       10 WS-B-ROT         PIC 9.
       10 WS-B-X           PIC S999 SIGN LEADING SEPARATE.
       10 WS-B-Y           PIC S9 SIGN LEADING SEPARATE.
       10 WS-B-Z           PIC S999 SIGN LEADING SEPARATE.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-PARENT              BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-ROT                 BINARY-LONG.
 01 LS-CUR                 BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NAME                PIC X(24).
 01 LS-PX                  BINARY-LONG.
 01 LS-PY                  BINARY-LONG.
 01 LS-PZ                  BINARY-LONG.
 01 LS-OW                  BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-STOP                BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-BOOL                BINARY-DOUBLE.
 01 LS-GEN                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-NONE-X              BINARY-LONG.
 01 LS-NONE-Y              BINARY-LONG.
 01 LS-NONE-Z              BINARY-LONG.
 01 LS-RES                 BINARY-LONG.
 01 LS-BROT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEPTH                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-PARENT L-START L-RESULT.
     MOVE L-DEPTH TO LS-DEPTH
     MOVE L-PARENT TO LS-PARENT
     MOVE L-START TO LS-START
     MOVE EP-ROT(LS-PARENT) TO LS-ROT
     MOVE 1 TO L-RESULT
     MOVE 1 TO LS-OW
     MOVE 0 TO LS-NONE-X LS-NONE-Y LS-NONE-Z
     MOVE "fat_tower_base" TO LS-NAME
     MOVE -3 TO LS-PX LS-PZ
     MOVE 4 TO LS-PY
     CALL "ENDCITY-ADD" USING LS-NAME LS-PARENT LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-CUR
     MOVE "fat_tower_middle" TO LS-NAME
     MOVE 0 TO LS-PX LS-PZ
     CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
     MOVE LS-NEW TO LS-CUR
     MOVE 0 TO LS-STOP
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I > 1 OR LS-STOP = 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE LS-DRAW
         IF LS-DRAW = 0
             MOVE 1 TO LS-STOP
         ELSE
             MOVE 8 TO LS-PY
             CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
             MOVE LS-NEW TO LS-CUR
             PERFORM VARYING LS-J FROM 1 BY 1 UNTIL LS-J > 4
                 CALL "JRAND-NEXT" USING SP-RNG WS-BITS LS-BOOL
                 IF LS-BOOL NOT = 0
                     MOVE "bridge_end" TO LS-NAME
                     COMPUTE LS-BROT = FUNCTION MOD(LS-ROT + WS-B-ROT(LS-J), 4)
                     MOVE WS-B-X(LS-J) TO LS-PX
                     MOVE WS-B-Y(LS-J) TO LS-PY
                     MOVE WS-B-Z(LS-J) TO LS-PZ
                     CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-BROT LS-OW LS-NEW
                     MOVE 3 TO LS-GEN
                     COMPUTE LS-NEXT = LS-DEPTH + 1
                     CALL "ENDCITY-RECURSE" USING LS-GEN LS-NEXT LS-NEW LS-NONE-X LS-NONE-Y LS-NONE-Z LS-START LS-RES
                 END-IF
             END-PERFORM
             MOVE "fat_tower_middle" TO LS-NAME
             MOVE 0 TO LS-PX LS-PZ
         END-IF
     END-PERFORM
     MOVE "fat_tower_top" TO LS-NAME
     MOVE -2 TO LS-PX LS-PZ
     MOVE 8 TO LS-PY
     CALL "ENDCITY-ADD" USING LS-NAME LS-CUR LS-PX LS-PY LS-PZ LS-ROT LS-OW LS-NEW
     GOBACK.
 END PROGRAM ENDCITY-FAT-GEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-HOUSE.
*> USING x, y, z, rotation: startHouseTower (10.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTEC.
 01 WS-NAME                PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MX                  BINARY-LONG VALUE -1.
 01 WS-MZ                  BINARY-LONG VALUE -1.
 01 WS-Y0                  BINARY-LONG VALUE 0.
 01 WS-Y4                  BINARY-LONG VALUE 4.
 01 WS-Y8                  BINARY-LONG VALUE 8.
 01 WS-OW1                 BINARY-LONG VALUE 1.
 01 WS-OW0                 BINARY-LONG VALUE 0.
 01 WS-GEN                 BINARY-LONG VALUE 2.
 01 WS-DEPTH               BINARY-LONG VALUE 1.
 01 WS-FIRST               BINARY-LONG VALUE 1.
 01 WS-RES                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG VALUE 0.
 01 WS-NY                  BINARY-LONG VALUE 0.
 01 WS-NZ                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-ROT.
     MOVE 0 TO EC-COUNT EC-LOST EC-SHIP
     MOVE "base_floor" TO WS-NAME
     CALL "ENDCITY-ADD" USING WS-NAME WS-ZERO L-X L-Y L-Z L-ROT WS-OW1 WS-ROW
     MOVE "second_floor_1" TO WS-NAME
     CALL "ENDCITY-ADD" USING WS-NAME WS-ROW WS-MX WS-Y0 WS-MZ L-ROT WS-OW0 WS-NEW
     MOVE "third_floor_1" TO WS-NAME
     CALL "ENDCITY-ADD" USING WS-NAME WS-NEW WS-MX WS-Y4 WS-MZ L-ROT WS-OW0 WS-ROW
     MOVE "third_roof" TO WS-NAME
     CALL "ENDCITY-ADD" USING WS-NAME WS-ROW WS-MX WS-Y8 WS-MZ L-ROT WS-OW1 WS-NEW
     CALL "ENDCITY-RECURSE" USING WS-GEN WS-DEPTH WS-NEW WS-NX WS-NY WS-NZ WS-FIRST WS-RES
     GOBACK.
 END PROGRAM ENDCITY-HOUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-CORNER.
*> USING rotation, sx out, sz out: the corner offsets of getLowestYIn5by5Box for each rotation (8.2 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-SX L-SZ.
     MOVE 5 TO L-SX L-SZ
     EVALUATE L-ROT
         WHEN 1
             MOVE -5 TO L-SX
         WHEN 2
             MOVE -5 TO L-SX L-SZ
         WHEN 3
             MOVE -5 TO L-SZ
     END-EVALUATE
     GOBACK.
 END PROGRAM ENDCITY-CORNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTEC.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LOWEST               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-LOWEST L-VALID.
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG L-SEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-FOUR WS-ROT
     MOVE 0 TO L-VALID EC-COUNT
     IF L-LOWEST < 60
         GOBACK
     END-IF
     COMPUTE WS-X = L-CX * 16 + 7
     COMPUTE WS-Z = L-CZ * 16 + 7
     CALL "ENDCITY-HOUSE" USING WS-X L-LOWEST WS-Z WS-ROT
     MOVE 1 TO L-VALID
     GOBACK.
 END PROGRAM ENDCITY-START.
