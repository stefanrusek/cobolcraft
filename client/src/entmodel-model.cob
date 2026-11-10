*> Entity models, the model data library (docs/protocol/34-entity-models-2-... onward). Records: client/copy/CLEMM.cpy.
*> Entry points for the integrator (inputs):
*>   EMM-INIT EMM-MODEL: an empty model with the root part (1) only.
*>   EMM-ROW EMM-MODEL row(X(100)) grow(3 FLOAT-LONG: gx gy gz): one definition row, tokens separated by spaces:
*>     "T w h" texture size; "P name parent px py pz rx ry rz [sx sy sz]" adds a part under the named parent (parent "root" is the root); a part of that
*>     name under that parent is replaced and keeps its children (34-1 2.1); "C part u v ox oy oz w h d g m" adds a cuboid to the named part, g = a number
*>     or "g", "g+n", "g-n" (the grow argument of the call, each axis, plus n), m = 1 for mirror; "X part" empties the cuboids of a part (clearChild).
*>   EMM-FIND EMM-MODEL name index(out, 0 absent; the part visited last wins as in 34-1 1.5, so the highest index of that name).
*>   EMM-RESET EMM-MODEL: the current pose of every part := its initial pose. EMM-CHAIN-POINT EMM-MODEL part point(3 floats, pixels) out(3, blocks): a
*>   point of the part's local space carried through the current poses up to the root (translate / rotate Z-Y-X / scale, each ancestor in turn, then / 16).
*>   EMM-CUBE-IN EMM-MODEL part cube EM1-CUBE-IN: one cuboid as the input of EM1-CUBE (34-1 1.3), with the model's texture size.
*>   EMM-STATS EMM-MODEL parts(out) cuboids(out): number of parts below the root and total cuboids.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-INIT.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     MOVE 1 TO MM-COUNT
     MOVE "root" TO MM-NAME(1)
     MOVE 0 TO MM-PARENT(1) MM-NCUBES(1)
     MOVE 1 TO MM-VISIBLE(1)
     MOVE 0 TO MM-X(1) MM-Y(1) MM-Z(1) MM-XROT(1) MM-YROT(1) MM-ZROT(1)
     MOVE 1 TO MM-XSCALE(1) MM-YSCALE(1) MM-ZSCALE(1)
     MOVE MM-INIT(1) TO MM-CUR(1)
     MOVE 64 TO MM-TEXW MM-TEXH
     GOBACK.
 END PROGRAM EMM-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-NAME                 PIC X(24).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-NAME L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MM-COUNT
         IF MM-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMM-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOK                 PIC X(24) OCCURS 14 TIMES.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NUM                 FLOAT-LONG OCCURS 14 TIMES.
 01 WS-G                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-OFF                 FLOAT-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-ROW                  PIC X(100).
 01 L-GROW.
    05 L-G                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-ROW L-GROW.
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 14
         MOVE SPACES TO WS-TOK(WS-K)
     END-PERFORM
     PERFORM UNTIL WS-PTR > 100 OR WS-N >= 14
         ADD 1 TO WS-N
         UNSTRING L-ROW DELIMITED BY ALL SPACE INTO WS-TOK(WS-N) WITH POINTER WS-PTR
         IF WS-TOK(WS-N) = SPACES
             SUBTRACT 1 FROM WS-N
             MOVE 101 TO WS-PTR
         END-IF
     END-PERFORM
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 14
         MOVE 0 TO WS-NUM(WS-K)
         IF WS-TOK(WS-K) NOT = SPACES AND WS-TOK(WS-K)(1:1) NOT = "g"
             COMPUTE WS-NUM(WS-K) = FUNCTION NUMVAL(WS-TOK(WS-K))
         END-IF
     END-PERFORM
     EVALUATE WS-TOK(1)(1:1)
         WHEN "T"
             MOVE WS-NUM(2) TO MM-TEXW
             MOVE WS-NUM(3) TO MM-TEXH
         WHEN "P"
*>           P name parent px py pz rx ry rz [sx sy sz]: tokens 2 3 are names, 4 to 9 the pose, 10 to 12 the scale
             MOVE WS-TOK(3) TO WS-NAME
             CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PARENT
             MOVE 0 TO WS-PART
             PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
                 IF MM-PARENT(WS-I) = WS-PARENT AND MM-NAME(WS-I) = WS-TOK(2)
                     MOVE WS-I TO WS-PART
                 END-IF
             END-PERFORM
             IF WS-PART = 0
                 ADD 1 TO MM-COUNT
                 MOVE MM-COUNT TO WS-PART
                 MOVE WS-TOK(2) TO MM-NAME(WS-PART)
                 MOVE WS-PARENT TO MM-PARENT(WS-PART)
                 MOVE 1 TO MM-VISIBLE(WS-PART)
             END-IF
             MOVE 0 TO MM-NCUBES(WS-PART)
             MOVE WS-NUM(4) TO MM-X(WS-PART)
             MOVE WS-NUM(5) TO MM-Y(WS-PART)
             MOVE WS-NUM(6) TO MM-Z(WS-PART)
             MOVE WS-NUM(7) TO MM-XROT(WS-PART)
             MOVE WS-NUM(8) TO MM-YROT(WS-PART)
             MOVE WS-NUM(9) TO MM-ZROT(WS-PART)
             MOVE 1 TO MM-XSCALE(WS-PART) MM-YSCALE(WS-PART) MM-ZSCALE(WS-PART)
             IF WS-TOK(10) NOT = SPACES
                 MOVE WS-NUM(10) TO MM-XSCALE(WS-PART)
                 MOVE WS-NUM(11) TO MM-YSCALE(WS-PART)
                 MOVE WS-NUM(12) TO MM-ZSCALE(WS-PART)
             END-IF
             MOVE MM-INIT(WS-PART) TO MM-CUR(WS-PART)
         WHEN "C"
             MOVE WS-TOK(2) TO WS-NAME
             PERFORM FIND-PART-HERE
             ADD 1 TO MM-NCUBES(WS-PART)
             MOVE MM-NCUBES(WS-PART) TO WS-C
             MOVE WS-NUM(3) TO MC-U(WS-PART, WS-C)
             MOVE WS-NUM(4) TO MC-V(WS-PART, WS-C)
             MOVE WS-NUM(5) TO MC-OX(WS-PART, WS-C)
             MOVE WS-NUM(6) TO MC-OY(WS-PART, WS-C)
             MOVE WS-NUM(7) TO MC-OZ(WS-PART, WS-C)
             MOVE WS-NUM(8) TO MC-W(WS-PART, WS-C)
             MOVE WS-NUM(9) TO MC-H(WS-PART, WS-C)
             MOVE WS-NUM(10) TO MC-D(WS-PART, WS-C)
             MOVE 0 TO WS-OFF
             IF WS-TOK(11)(1:1) = "g"
                 IF WS-TOK(11)(2:1) NOT = SPACE
                     COMPUTE WS-OFF = FUNCTION NUMVAL(WS-TOK(11)(2:))
                 END-IF
                 COMPUTE MC-GX(WS-PART, WS-C) = L-G(1) + WS-OFF
                 COMPUTE MC-GY(WS-PART, WS-C) = L-G(2) + WS-OFF
                 COMPUTE MC-GZ(WS-PART, WS-C) = L-G(3) + WS-OFF
             ELSE
                 MOVE WS-NUM(11) TO MC-GX(WS-PART, WS-C) MC-GY(WS-PART, WS-C) MC-GZ(WS-PART, WS-C)
             END-IF
             COMPUTE MC-MIRROR(WS-PART, WS-C) = WS-NUM(12)
         WHEN "X"
             MOVE WS-TOK(2) TO WS-NAME
             PERFORM FIND-PART-HERE
             MOVE 0 TO MM-NCUBES(WS-PART)
     END-EVALUATE
     GOBACK.

 FIND-PART-HERE.
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PART.
 END PROGRAM EMM-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MM-COUNT
         MOVE MM-INIT(WS-I) TO MM-CUR(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM EMM-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-CHAIN-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CA                  FLOAT-LONG.
 01 WS-SA                  FLOAT-LONG.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-PART                 BINARY-LONG.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-PART L-IN L-OUT.
     MOVE L-I(1) TO WS-X
     MOVE L-I(2) TO WS-Y
     MOVE L-I(3) TO WS-Z
     MOVE L-PART TO WS-NODE
     PERFORM UNTIL WS-NODE < 1
         COMPUTE WS-X = WS-X * MM-CXSCALE(WS-NODE)
         COMPUTE WS-Y = WS-Y * MM-CYSCALE(WS-NODE)
         COMPUTE WS-Z = WS-Z * MM-CZSCALE(WS-NODE)
         COMPUTE WS-CA = FUNCTION COS(MM-CXROT(WS-NODE))
         COMPUTE WS-SA = FUNCTION SIN(MM-CXROT(WS-NODE))
         COMPUTE WS-T = WS-Y * WS-CA - WS-Z * WS-SA
         COMPUTE WS-Z = WS-Y * WS-SA + WS-Z * WS-CA
         MOVE WS-T TO WS-Y
         COMPUTE WS-CA = FUNCTION COS(MM-CYROT(WS-NODE))
         COMPUTE WS-SA = FUNCTION SIN(MM-CYROT(WS-NODE))
         COMPUTE WS-T = WS-X * WS-CA + WS-Z * WS-SA
         COMPUTE WS-Z = WS-Z * WS-CA - WS-X * WS-SA
         MOVE WS-T TO WS-X
         COMPUTE WS-CA = FUNCTION COS(MM-CZROT(WS-NODE))
         COMPUTE WS-SA = FUNCTION SIN(MM-CZROT(WS-NODE))
         COMPUTE WS-T = WS-X * WS-CA - WS-Y * WS-SA
         COMPUTE WS-Y = WS-X * WS-SA + WS-Y * WS-CA
         MOVE WS-T TO WS-X
         COMPUTE WS-X = WS-X + MM-CX(WS-NODE)
         COMPUTE WS-Y = WS-Y + MM-CY(WS-NODE)
         COMPUTE WS-Z = WS-Z + MM-CZ(WS-NODE)
         MOVE MM-PARENT(WS-NODE) TO WS-NODE
     END-PERFORM
     COMPUTE L-O(1) = WS-X / 16
     COMPUTE L-O(2) = WS-Y / 16
     COMPUTE L-O(3) = WS-Z / 16
     GOBACK.
 END PROGRAM EMM-CHAIN-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-CUBE-IN.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-PART                 BINARY-LONG.
 01 L-CUBE                 BINARY-LONG.
 COPY CLEM1.
*> USING model part cube EM1-CUBE-IN: the cuboid as an input of EM1-CUBE (34-1 1.3) with the model's texture size and all six faces.
 PROCEDURE DIVISION USING EMM-MODEL L-PART L-CUBE EM1-CUBE-IN.
     MOVE MC-U(L-PART, L-CUBE) TO EC-U
     MOVE MC-V(L-PART, L-CUBE) TO EC-V
     MOVE MC-OX(L-PART, L-CUBE) TO EC-OX
     MOVE MC-OY(L-PART, L-CUBE) TO EC-OY
     MOVE MC-OZ(L-PART, L-CUBE) TO EC-OZ
     MOVE MC-W(L-PART, L-CUBE) TO EC-W
     MOVE MC-H(L-PART, L-CUBE) TO EC-H
     MOVE MC-D(L-PART, L-CUBE) TO EC-D
     MOVE MC-GX(L-PART, L-CUBE) TO EC-GX
     MOVE MC-GY(L-PART, L-CUBE) TO EC-GY
     MOVE MC-GZ(L-PART, L-CUBE) TO EC-GZ
     MOVE 1 TO EC-SU EC-SV
     MOVE MM-TEXW TO EC-TEXW
     MOVE MM-TEXH TO EC-TEXH
     MOVE MC-MIRROR(L-PART, L-CUBE) TO EC-MIRROR
     MOVE 63 TO EC-FACES
     GOBACK.
 END PROGRAM EMM-CUBE-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMM-STATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-PARTS                BINARY-LONG.
 01 L-CUBES                BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-PARTS L-CUBES.
     COMPUTE L-PARTS = MM-COUNT - 1
     MOVE 0 TO L-CUBES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MM-COUNT
         ADD MM-NCUBES(WS-I) TO L-CUBES
     END-PERFORM
     GOBACK.
 END PROGRAM EMM-STATS.
