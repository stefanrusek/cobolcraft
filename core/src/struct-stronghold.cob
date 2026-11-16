*> The stronghold, part 1: the start and the assembly of its pieces (docs/protocol/36-structures-5-mineshaft-stronghold.md sections 3.2 to 3.6; the blocks are in struct-sh-place.cob).
*> Pieces go into the builder of struct-pieces.cob (STRUCTPIECE.cpy), the generation state is STRUCTSH.cpy, the random is the Java LCG SP-RNG. Piece types are the registry ids of 36-1 2.4:
*> 19 shcc, 20 shfc, 21 sh5c, 22 shlt, 23 shli, 24 shpr, 25 shph, 26 shrt, 27 shrc, 28 shsd, 29 shstart, 30 shs, 31 shssd. Directions are data values: 0 south, 1 west, 2 north, 3 east.
*> Piece fields: SP-F1 the entry door (0 opening, 1 wood door, 2 grates, 3 iron door); SP-F2 to SP-F4 and SP-MST the type fields: straight left (F2) and right (F3) child, room crossing type (F2),
*> five crossing leftLow (F2), leftHigh (F3), rightLow (F4) and rightHigh (MST), library tall (F2), stairs down source (F2), filler corridor steps (F2).
*> Deviation: the retry loop of generatePieces has no cap in the artifact; here it stops after 1000 attempts (the start then stays as the last attempt, valid 0); a full builder (1024 pieces) makes
*> an attempt fail as in the mineshaft.
*>
*> Entry points:
*>   SH-FIND-POINT USING seed (BINARY-DOUBLE), chunk x, chunk z, sea level, min y, stub x out, stub y out, stub z out, valid out: StrongholdStructure.generatePieces (3.2)
*>   SH-RESET: resetPieces (3.3); SH-UPDATE-WEIGHT USING any out: updatePieceWeight (3.3)
*>   SH-MAKE USING class (1 to 11), x y z, direction, genDepth, row out: the factory of 3.5 (a box that fails or collides: row 0, no draw)
*>   SH-PICK USING x y z, direction, depth, row out: generatePieceFromSmallDoor (3.4); SH-GEN-ADD USING x y z, direction, depth, row out: generateAndAddPiece (3.4)
*>   SH-CHILDREN USING row: addChildren of the piece in the row (3.5 helpers, 3.6, 3.7)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 01 WS-I                   BINARY-LONG.
 01 WS-WEIGHTS.
    05 FILLER              PIC 9(4) VALUE 4000.
    05 FILLER              PIC 9(4) VALUE 0505.
    05 FILLER              PIC 9(4) VALUE 2000.
    05 FILLER              PIC 9(4) VALUE 2000.
    05 FILLER              PIC 9(4) VALUE 1006.
    05 FILLER              PIC 9(4) VALUE 0505.
    05 FILLER              PIC 9(4) VALUE 0505.
    05 FILLER              PIC 9(4) VALUE 0504.
    05 FILLER              PIC 9(4) VALUE 0504.
    05 FILLER              PIC 9(4) VALUE 1002.
    05 FILLER              PIC 9(4) VALUE 2001.
 01 WS-TAB REDEFINES WS-WEIGHTS.
    05 WS-ENTRY            OCCURS 11 TIMES.
       10 WS-WEIGHT        PIC 99.
       10 WS-MAX           PIC 99.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-WEIGHT(WS-I) TO SH-W(WS-I)
         MOVE WS-MAX(WS-I) TO SH-MAX(WS-I)
         MOVE 0 TO SH-CNT(WS-I)
         MOVE 1 TO SH-IN(WS-I)
     END-PERFORM
     MOVE 0 TO SH-IMPOSED SH-PREV SH-PORTAL SH-START SH-PEND-N
     GOBACK.
 END PROGRAM SH-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-UPDATE-WEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ANY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ANY.
     MOVE 0 TO L-ANY SH-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         IF SH-IN(WS-I) = 1
             ADD SH-W(WS-I) TO SH-TOTAL
             IF SH-MAX(WS-I) > 0 AND SH-CNT(WS-I) < SH-MAX(WS-I)
                 MOVE 1 TO L-ANY
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SH-UPDATE-WEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-DOOR.
*> USING door out: randomSmallDoor (3.5): nextInt(5), 0 and 1 opening, 2 wood door, 3 grates, 4 iron door.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOUND               BINARY-LONG VALUE 5.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DOOR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DOOR.
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     IF WS-DRAW < 2
         MOVE 0 TO L-DOOR
     ELSE
         COMPUTE L-DOOR = WS-DRAW - 1
     END-IF
     GOBACK.
 END PROGRAM SH-DOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-MAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-SPECS.
    05 FILLER              PIC X(13) VALUE "3011005005007".
    05 FILLER              PIC X(13) VALUE "2511009005011".
    05 FILLER              PIC X(13) VALUE "2211005005005".
    05 FILLER              PIC X(13) VALUE "2611005005005".
    05 FILLER              PIC X(13) VALUE "2741011007011".
    05 FILLER              PIC X(13) VALUE "3117005011008".
    05 FILLER              PIC X(13) VALUE "2817005011005".
    05 FILLER              PIC X(13) VALUE "2143010009011".
    05 FILLER              PIC X(13) VALUE "1911005005007".
    05 FILLER              PIC X(13) VALUE "2341014011015".
    05 FILLER              PIC X(13) VALUE "2441011008016".
 01 WS-SPEC-TAB REDEFINES WS-SPECS.
    05 WS-SPEC             OCCURS 11 TIMES.
       10 WS-S-TYPE        PIC 99.
       10 WS-S-OFFX        PIC 9.
       10 WS-S-OFFY        PIC 9.
       10 WS-S-W           PIC 999.
       10 WS-S-H           PIC 999.
       10 WS-S-D           PIC 999.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-OFFX                BINARY-LONG.
 01 WS-OFFY                BINARY-LONG.
 01 WS-OFFZ                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COLL                BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BIG                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-X L-Y L-Z L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     MOVE WS-S-TYPE(L-CLASS) TO WS-TYPE
     COMPUTE WS-OFFX = 0 - WS-S-OFFX(L-CLASS)
     COMPUTE WS-OFFY = 0 - WS-S-OFFY(L-CLASS)
     MOVE WS-S-W(L-CLASS) TO WS-W
     MOVE WS-S-H(L-CLASS) TO WS-H
     MOVE WS-S-D(L-CLASS) TO WS-D
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 2 OR WS-OK = 1
*>       the library tries the tall box (11) first, then the low one (6)
         IF WS-TRY = 2
             IF L-CLASS NOT = 10
                 EXIT PERFORM
             END-IF
             MOVE 6 TO WS-H
         END-IF
         CALL "SPB-ORIENT-BOX" USING L-X L-Y L-Z WS-OFFX WS-OFFY WS-OFFZ WS-W WS-H WS-D L-DIR WS-BOX
         IF B-Y0 > 10
             CALL "SPB-FIND-COLLISION" USING WS-BOX WS-COLL
             IF WS-COLL = 0
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
     END-PERFORM
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "SPB-ADD" USING WS-TYPE L-DIR L-DEPTH WS-MST WS-BOX L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
*>   the constructor draws (3.5)
     IF L-CLASS NOT = 11
         CALL "SH-DOOR" USING SP-F1(L-ROW)
     END-IF
     EVALUATE L-CLASS
         WHEN 1
             MOVE 2 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             IF WS-DRAW = 0
                 MOVE 1 TO SP-F2(L-ROW)
             END-IF
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             IF WS-DRAW = 0
                 MOVE 1 TO SP-F3(L-ROW)
             END-IF
         WHEN 5
             MOVE 5 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND SP-F2(L-ROW)
         WHEN 8
             MOVE 1 TO WS-BOUND
             CALL "JRAND-NEXT" USING SP-RNG WS-BOUND WS-BIG
             IF WS-BIG NOT = 0
                 MOVE 1 TO SP-F2(L-ROW)
             END-IF
             CALL "JRAND-NEXT" USING SP-RNG WS-BOUND WS-BIG
             IF WS-BIG NOT = 0
                 MOVE 1 TO SP-F3(L-ROW)
             END-IF
             CALL "JRAND-NEXT" USING SP-RNG WS-BOUND WS-BIG
             IF WS-BIG NOT = 0
                 MOVE 1 TO SP-F4(L-ROW)
             END-IF
             MOVE 3 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             IF WS-DRAW > 0
                 MOVE 1 TO SP-MST(L-ROW)
             END-IF
         WHEN 10
             IF SP-Y1(L-ROW) - SP-Y0(L-ROW) + 1 > 6
                 MOVE 1 TO SP-F2(L-ROW)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SH-MAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-FILLER-BOX.
*> USING x y z, direction, box out, found out: FillerCorridor.findPieceBox (3.5): the 5 by 5 by 4 box, the piece it collides with, the longest corridor that stops short of that piece (found 0 for none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-B2.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==C-==.
 01 WS-COLL                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OFFX                BINARY-LONG VALUE -1.
 01 WS-OFFY                BINARY-LONG VALUE -1.
 01 WS-OFFZ                BINARY-LONG VALUE 0.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FIVE-H              BINARY-LONG VALUE 5.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==R-==.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-BOX L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "SPB-ORIENT-BOX" USING L-X L-Y L-Z WS-OFFX WS-OFFY WS-OFFZ WS-FIVE WS-FIVE-H WS-FOUR L-DIR WS-BOX
     CALL "SPB-FIND-COLLISION" USING WS-BOX WS-COLL
     IF WS-COLL = 0
         GOBACK
     END-IF
     IF SP-Y0(WS-COLL) = B-Y0
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-D FROM 2 BY -1 UNTIL WS-D < 1 OR WS-DONE = 1
             CALL "SPB-ORIENT-BOX" USING L-X L-Y L-Z WS-OFFX WS-OFFY WS-OFFZ WS-FIVE WS-FIVE-H WS-D L-DIR WS-B2
             CALL "SPB-BOX-INTERSECTS" USING SP-BOX(WS-COLL) WS-B2 WS-FLAG
             IF WS-FLAG = 0
                 MOVE 1 TO WS-DONE
                 COMPUTE WS-D1 = WS-D + 1
                 CALL "SPB-ORIENT-BOX" USING L-X L-Y L-Z WS-OFFX WS-OFFY WS-OFFZ WS-FIVE WS-FIVE-H WS-D1 L-DIR L-BOX
                 MOVE 1 TO L-FOUND
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SH-FILLER-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 01 WS-ANY                 BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BREAK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-FILLER              BINARY-LONG VALUE 20.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     CALL "SH-UPDATE-WEIGHT" USING WS-ANY
     IF WS-ANY = 0
         GOBACK
     END-IF
     IF SH-IMPOSED > 0
         MOVE SH-IMPOSED TO WS-CLASS
         MOVE 0 TO SH-IMPOSED
         CALL "SH-MAKE" USING WS-CLASS L-X L-Y L-Z L-DIR L-DEPTH L-ROW
         IF L-ROW > 0
             GOBACK
         END-IF
     END-IF
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 5
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG SH-TOTAL WS-V
         MOVE 0 TO WS-BREAK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11 OR WS-BREAK = 1
             IF SH-IN(WS-I) = 1
                 SUBTRACT SH-W(WS-I) FROM WS-V
                 IF WS-V < 0
*>                   doPlace: the quota, and for the library (depth > 4) and the portal room (depth > 5) the depth
                     MOVE 1 TO WS-OK
                     IF SH-MAX(WS-I) > 0 AND SH-CNT(WS-I) >= SH-MAX(WS-I)
                         MOVE 0 TO WS-OK
                     END-IF
                     IF WS-I = 10 AND L-DEPTH <= 4
                         MOVE 0 TO WS-OK
                     END-IF
                     IF WS-I = 11 AND L-DEPTH <= 5
                         MOVE 0 TO WS-OK
                     END-IF
                     IF WS-OK = 0 OR WS-I = SH-PREV
                         MOVE 1 TO WS-BREAK
                     ELSE
                         CALL "SH-MAKE" USING WS-I L-X L-Y L-Z L-DIR L-DEPTH L-ROW
                         IF L-ROW > 0
                             ADD 1 TO SH-CNT(WS-I)
                             MOVE WS-I TO SH-PREV
                             IF SH-MAX(WS-I) > 0 AND SH-CNT(WS-I) >= SH-MAX(WS-I)
                                 MOVE 0 TO SH-IN(WS-I)
                             END-IF
                             GOBACK
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "SH-FILLER-BOX" USING L-X L-Y L-Z L-DIR WS-BOX WS-FOUND
     IF WS-FOUND = 1 AND B-Y0 > 1
         CALL "SPB-ADD" USING WS-FILLER L-DIR L-DEPTH WS-NONE WS-BOX L-ROW
         IF L-ROW > 0
             IF L-DIR = 2 OR L-DIR = 0
                 COMPUTE SP-F2(L-ROW) = B-Z1 - B-Z0 + 1
             ELSE
                 COMPUTE SP-F2(L-ROW) = B-X1 - B-X0 + 1
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SH-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-GEN-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 01 WS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     IF L-DEPTH > 50
         GOBACK
     END-IF
     IF FUNCTION ABS(L-X - SP-X0(SH-START)) > 112 OR FUNCTION ABS(L-Z - SP-Z0(SH-START)) > 112
         GOBACK
     END-IF
     COMPUTE WS-DEPTH = L-DEPTH + 1
     CALL "SH-PICK" USING L-X L-Y L-Z L-DIR WS-DEPTH L-ROW
     IF L-ROW > 0 AND SH-PEND-N < SH-PEND-MAX
         ADD 1 TO SH-PEND-N
         MOVE L-ROW TO SH-PEND(SH-PEND-N)
     END-IF
     GOBACK.
 END PROGRAM SH-GEN-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-CHILD.
*> USING parent row, kind (1 forward, 2 left, 3 right), a, b: the child helpers of StrongholdPiece (3.5); the child is added to the builder and the pending list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-AXIS-Z              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-A L-B.
     IF SP-ORIENT(L-ROW) < 0
         GOBACK
     END-IF
     MOVE 0 TO WS-AXIS-Z
     IF SP-ORIENT(L-ROW) = 0 OR SP-ORIENT(L-ROW) = 2
         MOVE 1 TO WS-AXIS-Z
     END-IF
     EVALUATE L-KIND
         WHEN 1
             MOVE SP-ORIENT(L-ROW) TO WS-DIR
             EVALUATE SP-ORIENT(L-ROW)
                 WHEN 2
                     COMPUTE WS-X = SP-X0(L-ROW) + L-A
                     COMPUTE WS-Y = SP-Y0(L-ROW) + L-B
                     COMPUTE WS-Z = SP-Z0(L-ROW) - 1
                 WHEN 0
                     COMPUTE WS-X = SP-X0(L-ROW) + L-A
                     COMPUTE WS-Y = SP-Y0(L-ROW) + L-B
                     COMPUTE WS-Z = SP-Z1(L-ROW) + 1
                 WHEN 1
                     COMPUTE WS-X = SP-X0(L-ROW) - 1
                     COMPUTE WS-Y = SP-Y0(L-ROW) + L-B
                     COMPUTE WS-Z = SP-Z0(L-ROW) + L-A
                 WHEN OTHER
                     COMPUTE WS-X = SP-X1(L-ROW) + 1
                     COMPUTE WS-Y = SP-Y0(L-ROW) + L-B
                     COMPUTE WS-Z = SP-Z0(L-ROW) + L-A
             END-EVALUATE
         WHEN 2
             COMPUTE WS-Y = SP-Y0(L-ROW) + L-A
             IF WS-AXIS-Z = 1
                 MOVE 1 TO WS-DIR
                 COMPUTE WS-X = SP-X0(L-ROW) - 1
                 COMPUTE WS-Z = SP-Z0(L-ROW) + L-B
             ELSE
                 MOVE 2 TO WS-DIR
                 COMPUTE WS-X = SP-X0(L-ROW) + L-B
                 COMPUTE WS-Z = SP-Z0(L-ROW) - 1
             END-IF
         WHEN OTHER
             COMPUTE WS-Y = SP-Y0(L-ROW) + L-A
             IF WS-AXIS-Z = 1
                 MOVE 3 TO WS-DIR
                 COMPUTE WS-X = SP-X1(L-ROW) + 1
                 COMPUTE WS-Z = SP-Z0(L-ROW) + L-B
             ELSE
                 MOVE 0 TO WS-DIR
                 COMPUTE WS-X = SP-X0(L-ROW) + L-B
                 COMPUTE WS-Z = SP-Z1(L-ROW) + 1
             END-IF
     END-EVALUATE
     CALL "SH-GEN-ADD" USING WS-X WS-Y WS-Z WS-DIR SP-DEPTH(L-ROW) WS-NEW
     GOBACK.
 END PROGRAM SH-CHILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-CHILDREN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 01 WS-FWD                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG VALUE 2.
 01 WS-RIGHT               BINARY-LONG VALUE 3.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-N1                  BINARY-LONG VALUE 1.
 01 WS-N1B                 BINARY-LONG VALUE 1.
 01 WS-N2                  BINARY-LONG VALUE 2.
 01 WS-N4                  BINARY-LONG VALUE 4.
 01 WS-N5                  BINARY-LONG VALUE 5.
 01 WS-N7                  BINARY-LONG VALUE 7.
 01 WS-NORTH-EAST          BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-NORTH-EAST
     IF SP-ORIENT(L-ROW) = 2 OR SP-ORIENT(L-ROW) = 3
         MOVE 1 TO WS-NORTH-EAST
     END-IF
     EVALUATE SP-TYPE(L-ROW)
         WHEN 30
             CALL "SH-CHILD" USING L-ROW WS-FWD WS-N1 WS-N1B
             IF SP-F2(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-LEFT WS-N1 WS-N2
             END-IF
             IF SP-F3(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-N1 WS-N2
             END-IF
         WHEN 19 WHEN 25 WHEN 31
             CALL "SH-CHILD" USING L-ROW WS-FWD WS-N1 WS-N1B
         WHEN 28 WHEN 29
             IF SP-F2(L-ROW) = 1
                 MOVE 8 TO SH-IMPOSED
             END-IF
             CALL "SH-CHILD" USING L-ROW WS-FWD WS-N1 WS-N1B
         WHEN 22
             IF WS-NORTH-EAST = 1
                 CALL "SH-CHILD" USING L-ROW WS-LEFT WS-N1 WS-N1B
             ELSE
                 CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-N1 WS-N1B
             END-IF
         WHEN 26
             IF WS-NORTH-EAST = 1
                 CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-N1 WS-N1B
             ELSE
                 CALL "SH-CHILD" USING L-ROW WS-LEFT WS-N1 WS-N1B
             END-IF
         WHEN 27
             CALL "SH-CHILD" USING L-ROW WS-FWD WS-N4 WS-N1
             CALL "SH-CHILD" USING L-ROW WS-LEFT WS-N1 WS-N4
             CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-N1 WS-N4
         WHEN 21
             MOVE 3 TO WS-A
             MOVE 5 TO WS-B
             IF SP-ORIENT(L-ROW) = 1 OR SP-ORIENT(L-ROW) = 2
                 MOVE 5 TO WS-A
                 MOVE 3 TO WS-B
             END-IF
             CALL "SH-CHILD" USING L-ROW WS-FWD WS-N5 WS-N1
             IF SP-F2(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-LEFT WS-A WS-N1
             END-IF
             IF SP-F3(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-LEFT WS-B WS-N7
             END-IF
             IF SP-F4(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-A WS-N1
             END-IF
             IF SP-MST(L-ROW) = 1
                 CALL "SH-CHILD" USING L-ROW WS-RIGHT WS-B WS-N7
             END-IF
         WHEN 24
             IF SH-START > 0
                 MOVE L-ROW TO SH-PORTAL
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SH-CHILDREN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-ATTEMPT             BINARY-DOUBLE.
 01 WS-DONE                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-Y                   BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG VALUE 29.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FIVE-D              BINARY-LONG VALUE 5.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG VALUE 10.
 01 WS-DY                  BINARY-LONG.
 01 WS-DIRS.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 1.
 01 WS-DIR-TAB REDEFINES WS-DIRS.
    05 WS-DIR-OF           PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-SEA L-MIN-Y L-X L-Y L-Z L-VALID.
     MOVE 0 TO L-VALID
     COMPUTE L-X = L-CX * 16
     MOVE 0 TO L-Y
     COMPUTE L-Z = L-CZ * 16
     MOVE 0 TO WS-ATTEMPT WS-DONE
     PERFORM UNTIL WS-DONE = 1 OR WS-ATTEMPT >= 1000
         CALL "SPB-RESET"
*>       setLargeFeatureSeed(levelSeed + attempt, cx, cz): the attempt before its increment
         COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-ATTEMPT + WS-M64, WS-M64)
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
         ADD 1 TO WS-ATTEMPT
         CALL "SH-RESET"
         COMPUTE WS-X = L-CX * 16 + 2
         COMPUTE WS-Z = L-CZ * 16 + 2
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         MOVE WS-DIR-OF(WS-DRAW + 1) TO WS-DIR
         CALL "SPB-MAKE-BOX" USING WS-X WS-Y WS-Z WS-DIR WS-FIVE WS-ELEVEN WS-FIVE-D WS-BOX
         CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-NONE WS-BOX WS-ROW
         MOVE 1 TO SP-F2(WS-ROW)
         MOVE WS-ROW TO SH-START
         CALL "SH-CHILDREN" USING WS-ROW
         PERFORM UNTIL SH-PEND-N = 0
             MOVE SH-PEND-N TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             COMPUTE WS-PICK = WS-DRAW + 1
             MOVE SH-PEND(WS-PICK) TO WS-ROW
             PERFORM VARYING WS-DRAW FROM WS-PICK BY 1 UNTIL WS-DRAW >= SH-PEND-N
                 MOVE SH-PEND(WS-DRAW + 1) TO SH-PEND(WS-DRAW)
             END-PERFORM
             SUBTRACT 1 FROM SH-PEND-N
             CALL "SH-CHILDREN" USING WS-ROW
         END-PERFORM
         CALL "SPB-MOVE-BELOW-SEA" USING L-SEA L-MIN-Y WS-OFFSET WS-DY
         IF SP-COUNT > 0 AND SH-PORTAL > 0
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     MOVE WS-ATTEMPT TO SH-ATTEMPTS
     IF WS-DONE = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM SH-FIND-POINT.
