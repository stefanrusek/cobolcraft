*> The nether fortress's piece growth (docs/protocol/36-structures-8-nether-and-end.md sections 2 to 4; the geometry of the pieces, section 5, is not built here).
*> Entry points (pieces go to the builder of STRUCTPIECE.cpy, the random is SP-RNG, state in STRUCTFORT.cpy):
*>   FORT-START USING seed (BINARY-DOUBLE UNSIGNED), chunk x, chunk z: SPB-RESET, setLargeFeatureSeed, the direction draw and FORT-GROW at (minBlockX + 2, minBlockZ + 2) (2.1).
*>   FORT-GROW USING direction (2D data value), x, z: the start piece, the children while any are pending (a random pending piece each time) and moveInsideHeights(48, 70).
*>   FORT-ANCHOR USING helper (1 forward, 2 left, 3 right), row, p, q, ax, ay, az, direction out: the child anchors of 4.1.
*>   FORT-MAKE USING registry id, ax, ay, az, direction, generation depth, row out: createPiece (3.4, 4.2, 4.3): the box, the isOkBox and collision tests, the constructor draws, the piece in the builder.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-SIZE.
*> USING registry id, offx, offy, offz, width, height, depth out: the box constants of 4.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OX L-OY L-OZ L-W L-H L-D.
     MOVE 0 TO L-OZ
     EVALUATE L-TYPE
         WHEN 4
             MOVE -8 TO L-OX
             MOVE -3 TO L-OY
             MOVE 19 TO L-W
             MOVE 10 TO L-H
             MOVE 19 TO L-D
         WHEN 6
             MOVE -1 TO L-OX
             MOVE -3 TO L-OY
             MOVE 5 TO L-W
             MOVE 10 TO L-H
             MOVE 19 TO L-D
         WHEN 5
             MOVE -1 TO L-OX
             MOVE -3 TO L-OY
             MOVE 5 TO L-W
             MOVE 10 TO L-H
             MOVE 8 TO L-D
         WHEN 16
             MOVE -2 TO L-OX
             MOVE 0 TO L-OY
             MOVE 7 TO L-W
             MOVE 9 TO L-H
             MOVE 7 TO L-D
         WHEN 17
             MOVE -2 TO L-OX
             MOVE 0 TO L-OY
             MOVE 7 TO L-W
             MOVE 11 TO L-H
             MOVE 7 TO L-D
         WHEN 15
             MOVE -2 TO L-OX
             MOVE 0 TO L-OY
             MOVE 7 TO L-W
             MOVE 8 TO L-H
             MOVE 9 TO L-D
         WHEN 9
             MOVE -5 TO L-OX
             MOVE -3 TO L-OY
             MOVE 13 TO L-W
             MOVE 14 TO L-H
             MOVE 13 TO L-D
         WHEN 14
             MOVE -5 TO L-OX
             MOVE -3 TO L-OY
             MOVE 13 TO L-W
             MOVE 14 TO L-H
             MOVE 13 TO L-D
         WHEN 7
             MOVE -1 TO L-OX
             MOVE -7 TO L-OY
             MOVE 5 TO L-W
             MOVE 14 TO L-H
             MOVE 10 TO L-D
         WHEN 8
             MOVE -3 TO L-OX
             MOVE 0 TO L-OY
             MOVE 9 TO L-W
             MOVE 7 TO L-H
             MOVE 9 TO L-D
         WHEN OTHER
             MOVE -1 TO L-OX
             MOVE 0 TO L-OY
             MOVE 5 TO L-W
             MOVE 7 TO L-H
             MOVE 5 TO L-D
     END-EVALUATE
     GOBACK.
 END PROGRAM FORT-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-ANCHOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 LINKAGE SECTION.
 01 L-HELPER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-Q                    BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HELPER L-ROW L-P L-Q L-AX L-AY L-AZ L-DIR.
     EVALUATE L-HELPER
         WHEN 1
             MOVE SP-ORIENT(L-ROW) TO L-DIR
             COMPUTE L-AY = SP-Y0(L-ROW) + L-Q
             EVALUATE L-DIR
                 WHEN 2
                     COMPUTE L-AX = SP-X0(L-ROW) + L-P
                     COMPUTE L-AZ = SP-Z0(L-ROW) - 1
                 WHEN 0
                     COMPUTE L-AX = SP-X0(L-ROW) + L-P
                     COMPUTE L-AZ = SP-Z1(L-ROW) + 1
                 WHEN 1
                     COMPUTE L-AX = SP-X0(L-ROW) - 1
                     COMPUTE L-AZ = SP-Z0(L-ROW) + L-P
                 WHEN OTHER
                     COMPUTE L-AX = SP-X1(L-ROW) + 1
                     COMPUTE L-AZ = SP-Z0(L-ROW) + L-P
             END-EVALUATE
         WHEN 2
             COMPUTE L-AY = SP-Y0(L-ROW) + L-P
             IF SP-ORIENT(L-ROW) = 2 OR SP-ORIENT(L-ROW) = 0
                 COMPUTE L-AX = SP-X0(L-ROW) - 1
                 COMPUTE L-AZ = SP-Z0(L-ROW) + L-Q
                 MOVE 1 TO L-DIR
             ELSE
                 COMPUTE L-AX = SP-X0(L-ROW) + L-Q
                 COMPUTE L-AZ = SP-Z0(L-ROW) - 1
                 MOVE 2 TO L-DIR
             END-IF
         WHEN OTHER
             COMPUTE L-AY = SP-Y0(L-ROW) + L-P
             IF SP-ORIENT(L-ROW) = 2 OR SP-ORIENT(L-ROW) = 0
                 COMPUTE L-AX = SP-X1(L-ROW) + 1
                 COMPUTE L-AZ = SP-Z0(L-ROW) + L-Q
                 MOVE 3 TO L-DIR
             ELSE
                 COMPUTE L-AX = SP-X0(L-ROW) + L-Q
                 COMPUTE L-AZ = SP-Z1(L-ROW) + 1
                 MOVE 0 TO L-DIR
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FORT-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-MAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COLL                BINARY-LONG.
 01 WS-AUX                 BINARY-LONG.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-AX L-AY L-AZ L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     CALL "FORT-SIZE" USING L-TYPE WS-OX WS-OY WS-OZ WS-W WS-H WS-D
     CALL "SPB-ORIENT-BOX" USING L-AX L-AY L-AZ WS-OX WS-OY WS-OZ WS-W WS-H WS-D L-DIR WS-BOX
     IF B-Y0 <= 10
         GOBACK
     END-IF
     CALL "SPB-FIND-COLLISION" USING WS-BOX WS-COLL
     IF WS-COLL > 0
         GOBACK
     END-IF
*>   the constructor's draws: a bridge end filler keeps a nextInt(), a turn piece rolls its chest
     MOVE 0 TO WS-AUX
     EVALUATE L-TYPE
         WHEN 5
             CALL "JRAND-NEXT" USING SP-RNG WS-BITS WS-SEED
             COMPUTE WS-AUX = WS-SEED
         WHEN 11
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE WS-AUX
         WHEN 13
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-THREE WS-AUX
     END-EVALUATE
     CALL "SPB-ADD" USING L-TYPE L-DIR L-DEPTH WS-ZERO WS-BOX L-ROW
     IF L-ROW > 0
         MOVE WS-AUX TO SP-F1(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM FORT-MAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-PICK.
*> USING first entry, last entry (the table), ax, ay, az, direction, generation depth (the parent's plus 1), row out: generatePiece (3.4) including the end filler of its step 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTFORT.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LIMITED             BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-SELECTED            BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-FILLER              BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 01 L-LO                   BINARY-LONG.
 01 L-HI                   BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LO L-HI L-AX L-AY L-AZ L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     MOVE 0 TO WS-TOTAL WS-LIMITED
     PERFORM VARYING WS-E FROM L-LO BY 1 UNTIL WS-E > L-HI
         IF FE-LIVE(WS-E) = 1
             ADD FE-WEIGHT(WS-E) TO WS-TOTAL
             IF FE-MAX(WS-E) > 0
                 MOVE 1 TO WS-LIMITED
             END-IF
         END-IF
     END-PERFORM
     IF WS-LIMITED = 0
         MOVE -1 TO WS-TOTAL
     END-IF
     MOVE 0 TO WS-TRIES
     IF WS-TOTAL > 0 AND L-DEPTH <= 30
         PERFORM UNTIL WS-TRIES >= 5 OR L-ROW > 0
             ADD 1 TO WS-TRIES
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-TOTAL WS-R
             MOVE 0 TO WS-SELECTED WS-STOP
             PERFORM VARYING WS-E FROM L-LO BY 1 UNTIL WS-E > L-HI OR WS-STOP = 1
                 IF FE-LIVE(WS-E) = 1
                     IF WS-SELECTED = 0
                         SUBTRACT FE-WEIGHT(WS-E) FROM WS-R
                         IF WS-R < 0
                             MOVE 1 TO WS-SELECTED
                         END-IF
                     END-IF
                     IF WS-SELECTED = 1
                         IF WS-E = FO-PREV AND FE-ROW(WS-E) = 0
                             MOVE 1 TO WS-STOP
                         ELSE
                             CALL "FORT-MAKE" USING FE-TYPE(WS-E) L-AX L-AY L-AZ L-DIR L-DEPTH L-ROW
                             IF L-ROW > 0
                                 ADD 1 TO FE-PLACED(WS-E)
                                 MOVE WS-E TO FO-PREV
                                 IF FE-MAX(WS-E) > 0 AND FE-PLACED(WS-E) >= FE-MAX(WS-E)
                                     MOVE 0 TO FE-LIVE(WS-E)
                                 END-IF
                                 MOVE 1 TO WS-STOP
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     IF L-ROW = 0
         CALL "FORT-MAKE" USING WS-FILLER L-AX L-AY L-AZ L-DIR L-DEPTH L-ROW
     END-IF
     GOBACK.
 END PROGRAM FORT-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEN.
*> USING ax, ay, az, direction, the parent's generation depth, castle flag: generateAndAddPiece (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTFORT.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-FILLER              BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-CASTLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-AX L-AY L-AZ L-DIR L-DEPTH L-CASTLE.
     COMPUTE WS-DX = FUNCTION ABS(L-AX - FO-SX)
     COMPUTE WS-DZ = FUNCTION ABS(L-AZ - FO-SZ)
     IF WS-DX > 112 OR WS-DZ > 112
*>       a filler that is created is not added and not pending (it still drew its seed)
         CALL "FORT-MAKE" USING WS-FILLER L-AX L-AY L-AZ L-DIR L-DEPTH WS-ROW
         IF WS-ROW > 0
             SUBTRACT 1 FROM SP-COUNT
         END-IF
         GOBACK
     END-IF
     IF L-CASTLE = 1
         MOVE 7 TO WS-LO
         MOVE 13 TO WS-HI
     ELSE
         MOVE 1 TO WS-LO
         MOVE 6 TO WS-HI
     END-IF
     COMPUTE WS-DEPTH = L-DEPTH + 1
     CALL "FORT-PICK" USING WS-LO WS-HI L-AX L-AY L-AZ L-DIR WS-DEPTH WS-ROW
     IF WS-ROW > 0
         ADD 1 TO FO-PEND-N
         MOVE WS-ROW TO FO-PEND(FO-PEND-N)
     END-IF
     GOBACK.
 END PROGRAM FORT-GEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-CHILDREN.
*> USING row: addChildren of the piece (4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-SPEC                PIC X(18).
 01 WS-I                   BINARY-LONG.
 01 WS-HELPER              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-CASTLE              BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG VALUE 2.
 01 WS-RIGHT               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-DEPTH(L-ROW) TO WS-DEPTH
     MOVE SPACES TO WS-SPEC
     EVALUATE SP-TYPE(L-ROW)
         WHEN 4
             MOVE "F0803BL0308BR0308B" TO WS-SPEC
         WHEN 18
             MOVE "F0803BL0308BR0308B" TO WS-SPEC
         WHEN 6
             MOVE "F0103B" TO WS-SPEC
         WHEN 16
             MOVE "F0200BL0002BR0002B" TO WS-SPEC
         WHEN 17
             MOVE "R0602B" TO WS-SPEC
         WHEN 9
             MOVE "F0503C" TO WS-SPEC
         WHEN 14
             MOVE "F0503CF0511C" TO WS-SPEC
         WHEN 12
             MOVE "F0100C" TO WS-SPEC
         WHEN 10
             MOVE "F0100CL0001CR0001C" TO WS-SPEC
         WHEN 11
             MOVE "L0001C" TO WS-SPEC
         WHEN 13
             MOVE "R0001C" TO WS-SPEC
         WHEN 7
             MOVE "F0100C" TO WS-SPEC
     END-EVALUATE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 3
         COMPUTE WS-I = (WS-N - 1) * 6 + 1
         IF WS-SPEC(WS-I:1) NOT = SPACE
         EVALUATE WS-SPEC(WS-I:1)
             WHEN "F"
                 MOVE 1 TO WS-HELPER
             WHEN "L"
                 MOVE 2 TO WS-HELPER
             WHEN OTHER
                 MOVE 3 TO WS-HELPER
         END-EVALUATE
         COMPUTE WS-P = FUNCTION NUMVAL(WS-SPEC(WS-I + 1:2))
         COMPUTE WS-Q = FUNCTION NUMVAL(WS-SPEC(WS-I + 3:2))
         MOVE 0 TO WS-CASTLE
         IF WS-SPEC(WS-I + 5:1) = "C"
             MOVE 1 TO WS-CASTLE
         END-IF
         CALL "FORT-ANCHOR" USING WS-HELPER L-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
         CALL "FORT-GEN" USING WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CASTLE
         END-IF
     END-PERFORM
*>   the T balcony: each side draws first whether it is a castle child (7 in 8)
     IF SP-TYPE(L-ROW) = 8
         MOVE 1 TO WS-K
         IF SP-ORIENT(L-ROW) = 1 OR SP-ORIENT(L-ROW) = 2
             MOVE 5 TO WS-K
         END-IF
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-EIGHT WS-DRAW
         MOVE 0 TO WS-CASTLE
         IF WS-DRAW > 0
             MOVE 1 TO WS-CASTLE
         END-IF
         CALL "FORT-ANCHOR" USING WS-LEFT L-ROW WS-ZERO WS-K WS-AX WS-AY WS-AZ WS-DIR
         CALL "FORT-GEN" USING WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CASTLE
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-EIGHT WS-DRAW
         MOVE 0 TO WS-CASTLE
         IF WS-DRAW > 0
             MOVE 1 TO WS-CASTLE
         END-IF
         CALL "FORT-ANCHOR" USING WS-RIGHT L-ROW WS-ZERO WS-K WS-AX WS-AY WS-AZ WS-DIR
         CALL "FORT-GEN" USING WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CASTLE
     END-IF
     GOBACK.
 END PROGRAM FORT-CHILDREN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTFORT.
*> the tables: type (registry id), weight, maximum, allowInRow, in order bridge then castle
 01 WS-TABLE.
    05 FILLER PIC X(8) VALUE "0630001 ".
    05 FILLER PIC X(8) VALUE "0410040 ".
    05 FILLER PIC X(8) VALUE "1610040 ".
    05 FILLER PIC X(8) VALUE "1710030 ".
    05 FILLER PIC X(8) VALUE "1505020 ".
    05 FILLER PIC X(8) VALUE "0905010 ".
    05 FILLER PIC X(8) VALUE "1225001 ".
    05 FILLER PIC X(8) VALUE "1015050 ".
    05 FILLER PIC X(8) VALUE "1305100 ".
    05 FILLER PIC X(8) VALUE "1105100 ".
    05 FILLER PIC X(8) VALUE "0710031 ".
    05 FILLER PIC X(8) VALUE "0807020 ".
    05 FILLER PIC X(8) VALUE "1405020 ".
 01 WS-TAB REDEFINES WS-TABLE.
    05 WS-T OCCURS 13 TIMES.
       10 WS-T-TYPE        PIC 99.
       10 WS-T-WEIGHT      PIC 99.
       10 WS-T-MAX         PIC 99.
       10 WS-T-ROW         PIC 9.
       10 FILLER           PIC X.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 18.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG VALUE 64.
 01 WS-AZ                  BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-SPAN                BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-NEW-MIN             BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-X L-Z.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE WS-T-TYPE(WS-I) TO FE-TYPE(WS-I)
         MOVE WS-T-WEIGHT(WS-I) TO FE-WEIGHT(WS-I)
         MOVE WS-T-MAX(WS-I) TO FE-MAX(WS-I)
         MOVE WS-T-ROW(WS-I) TO FE-ROW(WS-I)
         MOVE 0 TO FE-PLACED(WS-I)
         MOVE 1 TO FE-LIVE(WS-I)
     END-PERFORM
     MOVE 0 TO FO-PREV FO-PEND-N
     MOVE L-X TO FO-SX WS-AX
     MOVE L-Z TO FO-SZ WS-AZ
*>   the start piece: BridgeCrossing's box at (x, 64, z), always 19 by 10 by 19 (4.2)
     COMPUTE B-X0 = L-X
     MOVE 64 TO B-Y0
     COMPUTE B-Z0 = L-Z
     COMPUTE B-X1 = L-X + 18
     MOVE 73 TO B-Y1
     COMPUTE B-Z1 = L-Z + 18
     CALL "SPB-ADD" USING WS-TYPE L-DIR WS-DEPTH WS-ZERO WS-BOX WS-ROW
     CALL "FORT-CHILDREN" USING WS-ROW
     PERFORM UNTIL FO-PEND-N = 0
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG FO-PEND-N WS-PICK
         COMPUTE WS-PICK = WS-PICK + 1
         MOVE FO-PEND(WS-PICK) TO WS-ROW
         PERFORM VARYING WS-J FROM WS-PICK BY 1 UNTIL WS-J >= FO-PEND-N
             MOVE FO-PEND(WS-J + 1) TO FO-PEND(WS-J)
         END-PERFORM
         SUBTRACT 1 FROM FO-PEND-N
         CALL "FORT-CHILDREN" USING WS-ROW
     END-PERFORM
*>   moveInsideHeights(48, 70) (2.1 step 4, 36-1 6.6)
     CALL "SPB-UNION-ALL" USING WS-BOX
     COMPUTE WS-SPAN = B-Y1 - B-Y0 + 1
     COMPUTE WS-ROOM = 23 - WS-SPAN
     MOVE 48 TO WS-NEW-MIN
     IF WS-ROOM > 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-ROOM WS-DRAW
         ADD WS-DRAW TO WS-NEW-MIN
     END-IF
     COMPUTE WS-DY = WS-NEW-MIN - B-Y0
     CALL "SPB-OFFSET" USING WS-DY
     GOBACK.
 END PROGRAM FORT-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ.
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG L-SEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-4 WS-DRAW
*>   NORTH, EAST, SOUTH, WEST as the builder's data values
     EVALUATE WS-DRAW
         WHEN 0
             MOVE 2 TO WS-DIR
         WHEN 1
             MOVE 3 TO WS-DIR
         WHEN 2
             MOVE 0 TO WS-DIR
         WHEN OTHER
             MOVE 1 TO WS-DIR
     END-EVALUATE
     COMPUTE WS-X = L-CX * 16 + 2
     COMPUTE WS-Z = L-CZ * 16 + 2
     CALL "FORT-GROW" USING WS-DIR WS-X WS-Z
     GOBACK.
 END PROGRAM FORT-START.
