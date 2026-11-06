*> Implementation test of client/src/models.cob (MODEL-RESOLVE, ELEMENT-BAKE, VARIANT-ROTATE,
*> MODELS-BAKE; 08 §5.2 to §5.5, §5.4.1, §5.5.1, §4.3): parent resolution (elements from the nearest
*> model that has them, texture slots merged with the child winning), "#" references, a missing
*> model, the default UV formula, explicit UVs, face rotation, the element rotation rule (single
*> axis with and without rescale, Euler x then y then z), the Variant rotation, and the quads baked
*> per block state of the built-in pack.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MODELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLMODEL.
 COPY CLQUAD.
 COPY TESTLIB.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FACE                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG VALUE 3.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OUT                 PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E                   PIC -9.999.
 01 WS-E2                  PIC Z9.999.
 01 WS-N                   PIC Z9.
 01 WS-COUNTS              PIC X(18).
 COPY JSONDOC.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NODE                BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXTURE             PIC X(80).
 01 WS-SPRITE2             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE

     MOVE "cobolcraft:block/turf" TO WS-ID
     MOVE 21 TO WS-ID-LENGTH
     CALL "MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
     MOVE "models turf: one element from template_box; slots of turf, template_layered and "
         & "template_box merged, the child winning" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 1 top=cobolcraft:block/turf_top particle=#side up=#top" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MR-ELEMENT-COUNT TO WS-N
     STRING MR-MISSING " " FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MR-SLOT-COUNT
         IF MS-NAME(WS-I) = "up" OR "top" OR "particle"
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(MS-NAME(WS-I)) "="
                 FUNCTION TRIM(MS-VALUE(WS-I)) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft:block/nothing" TO WS-ID
     MOVE 24 TO WS-ID-LENGTH
     CALL "MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
     MOVE "models a model id that names no file is missing (08 §5.2)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MR-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "block/greystone" TO WS-ID
     MOVE 15 TO WS-ID-LENGTH
     CALL "MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
     MOVE "models a model id without a namespace is looked up in minecraft (here: missing)"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MR-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Element and texture parsing of a hand-written model.
     INITIALIZE MODEL-RESOLVED
     MOVE '{"textures":{"a":"#b","b":{"sprite":"cobolcraft:block/loam"},"c":"block/loam"},'
         & '"elements":[{"from":[1,2,3],"to":[4,5,6],"rotation":{"origin":[8,7,6],"axis":"z",'
         & '"angle":22.5,"rescale":true},"shade_direction_override":"up","faces":{"north":'
         & '{"texture":"#a","uv":[0,1,2,3],"cullface":"south","rotation":-90}}},'
         & '{"from":[0,0,0],"to":[1,1,1],"rotation":{"origin":[0,0,0],"x":10,"y":20,"z":30},'
         & '"faces":{"up":{"texture":"#c"}}}]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE 1 TO MR-SLOT-COUNT
     MOVE "a" TO MS-NAME(1)
     MOVE "#keep" TO MS-VALUE(1)
     MOVE "textures" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
     CALL "MODEL-TEXTURES-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED
     MOVE "elements" TO WS-KEY
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE JN-FIRST(WS-NODE) TO WS-NODE
     MOVE 1 TO WS-I
     CALL "MODEL-ELEMENT-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED WS-I
     MOVE JN-NEXT(WS-NODE) TO WS-NODE
     MOVE 2 TO WS-I
     CALL "MODEL-ELEMENT-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED WS-I
     MOVE "models parsing: a set slot is kept, an object slot gives its sprite; from, to, single-"
         & "axis rotation, shade override, face texture, uv, cullface, rotation; Euler angles"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(MS-VALUE(1)) " " FUNCTION TRIM(MS-VALUE(2)) " "
         FUNCTION TRIM(MF-TEXTURE(1, DIR-NORTH)) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = ME-FROM(1, 2)
     STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = ME-TO(1, 3)
     STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E2 ROUNDED = ME-ROT-ANGLE(1, 1)
     MOVE ME-ROT-AXIS(1) TO WS-N
     STRING FUNCTION TRIM(WS-E2) " axis" FUNCTION TRIM(WS-N) " " DELIMITED BY SIZE
         INTO WS-OUT WITH POINTER WS-PTR
     MOVE ME-ROT-KIND(1) TO WS-N
     STRING "kind" FUNCTION TRIM(WS-N) " rescale" ME-RESCALE(1) DELIMITED BY SIZE
         INTO WS-OUT WITH POINTER WS-PTR
     MOVE ME-SHADE(1) TO WS-N
     STRING " shade" FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE MF-CULL(1, DIR-NORTH) TO WS-N
     STRING " cull" FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E2 ROUNDED = MF-UV(1, DIR-NORTH, 4)
     STRING " uv4=" FUNCTION TRIM(WS-E2) " rot" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE MF-ROTATION(1, DIR-NORTH) TO WS-COUNTS
     STRING FUNCTION TRIM(WS-COUNTS) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E2 ROUNDED = ME-ROT-ANGLE(2, 3)
     MOVE ME-ROT-KIND(2) TO WS-N
     STRING " euler" FUNCTION TRIM(WS-N) " z" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO WS-OUT WITH POINTER WS-PTR
     MOVE WS-OUT TO TL-OBSERVED
     MOVE "#keep cobolcraft:block/loam #a 2.000 6.000 22.500 axis3 kind1 rescale1 shade2 cull4 "
         & "uv4=3.000 rot000000270 euler2 z30.000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "#c" TO WS-TEXTURE
     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-TEXTURE WS-SPRITE
     MOVE "#nothing" TO WS-TEXTURE
     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-TEXTURE WS-SPRITE2
     MOVE "models a sprite id without a namespace is in minecraft; an unresolved reference is the "
         & "missing texture" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SPRITE * 10 + WS-SPRITE2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-I
     MOVE DIR-NORTH TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-I WS-FACE WS-SPRITE QUAD
     MOVE "models shade_direction_override up shades the north face as up; its cullface is south"
         TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = QD-CULL * 10 + QD-SHADE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-SPRITE

*>   Element bakes on a hand-made element (2, 0, 4) to (10, 8, 14).
     INITIALIZE MODEL-RESOLVED
     MOVE 1 TO MR-ELEMENT-COUNT
     MOVE 2 TO ME-FROM(1, 1)
     MOVE 0 TO ME-FROM(1, 2)
     MOVE 4 TO ME-FROM(1, 3)
     MOVE 10 TO ME-TO(1, 1)
     MOVE 8 TO ME-TO(1, 2)
     MOVE 14 TO ME-TO(1, 3)
     MOVE DIR-NORTH TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models default uv of a north face is [16 - tx, 16 - ty, 16 - fx, 16 - fy]; corners "
         & "top-left, top-right, bottom-right, bottom-left seen from outside" TO TL-CASE
     PERFORM SHOW-QUAD
     MOVE "(0.625 0.500 0.250 6.000 8.000)(0.125 0.500 0.250 14.000 8.000)"
         & "(0.125 0.000 0.250 14.000 16.000)(0.625 0.000 0.250 6.000 16.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 90 TO MF-ROTATION(1, DIR-NORTH)
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models face rotation 90 moves each corner's uv to the next corner clockwise" TO TL-CASE
     PERFORM SHOW-QUAD
     MOVE "(0.625 0.500 0.250 6.000 16.000)(0.125 0.500 0.250 6.000 8.000)"
         & "(0.125 0.000 0.250 14.000 8.000)(0.625 0.000 0.250 14.000 16.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO MF-UV-GIVEN(1, DIR-UP)
     MOVE 1 TO MF-UV(1, DIR-UP, 1)
     MOVE 2 TO MF-UV(1, DIR-UP, 2)
     MOVE 3 TO MF-UV(1, DIR-UP, 3)
     MOVE 4 TO MF-UV(1, DIR-UP, 4)
     MOVE DIR-UP TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models an explicit uv on the up face: top edge north, right edge east" TO TL-CASE
     PERFORM SHOW-QUAD
     MOVE "(0.125 0.500 0.250 1.000 2.000)(0.625 0.500 0.250 3.000 2.000)"
         & "(0.625 0.500 0.875 3.000 4.000)(0.125 0.500 0.875 1.000 4.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE DIR-DOWN TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models default uv of a down face [fx, 16 - tz, tx, 16 - fz]: top edge south" TO TL-CASE
     PERFORM SHOW-QUAD
     MOVE "(0.125 0.000 0.875 2.000 2.000)(0.625 0.000 0.875 10.000 2.000)"
         & "(0.625 0.000 0.250 10.000 12.000)(0.125 0.000 0.250 2.000 12.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "models default uv of south, west and east faces" TO TL-CASE
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-FACE FROM DIR-SOUTH BY 1 UNTIL WS-FACE > DIR-EAST
         CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
         PERFORM VARYING WS-K FROM 1 BY 2 UNTIL WS-K > 3
             COMPUTE WS-E2 ROUNDED = QD-U(WS-K)
             STRING WS-E2 DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
             COMPUTE WS-E2 ROUNDED = QD-V(WS-K)
             STRING WS-E2 DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         END-PERFORM
     END-PERFORM
     MOVE WS-OUT TO TL-OBSERVED
     MOVE " 2.000 8.00010.00016.000 4.000 8.00014.00016.000 2.000 8.00012.00016.000"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Element rotations on a full cube, origin (8, 8, 8).
     INITIALIZE MODEL-RESOLVED
     MOVE 1 TO MR-ELEMENT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 0 TO ME-FROM(1, WS-I)
         MOVE 16 TO ME-TO(1, WS-I)
         MOVE 8 TO ME-ROT-ORIGIN(1, WS-I)
     END-PERFORM
     MOVE 1 TO ME-ROT-KIND(1)
     MOVE 2 TO ME-ROT-AXIS(1)
     MOVE 90 TO ME-ROT-ANGLE(1, 1)
     MOVE DIR-EAST TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models element rotation axis y angle 90 turns the east side to the north side" TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE "(1.000 1.000 0.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO ME-ROT-AXIS(1)
     MOVE 45 TO ME-ROT-ANGLE(1, 1)
     MOVE 1 TO ME-RESCALE(1)
     MOVE DIR-SOUTH TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models element rotation axis z angle 45 with rescale scales x and y by the square root "
         & "of 2" TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE "(-0.500 0.500 1.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO ME-ROT-AXIS(1)
     MOVE 0 TO ME-RESCALE(1)
     MOVE 90 TO ME-ROT-ANGLE(1, 1)
     MOVE DIR-UP TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models element rotation axis x angle 90 (right-handed) moves the top-left of the up face "
         & "from north to south" TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE "(0.000 1.000 1.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO ME-ROT-KIND(1)
     MOVE 90 TO ME-ROT-ANGLE(1, 1) ME-ROT-ANGLE(1, 2)
     MOVE 0 TO ME-ROT-ANGLE(1, 3)
     MOVE 1 TO ME-RESCALE(1)
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models Euler rotation x 90 then y 90 (rescale ignored)" TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE "(1.000 1.000 1.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO ME-ROT-ANGLE(1, 1) ME-ROT-ANGLE(1, 2)
     MOVE 90 TO ME-ROT-ANGLE(1, 3)
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE "models Euler rotation z 90 alone moves the top-left of the up face down to (0, 0, 0)"
         TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE "(0.000 0.000 0.000)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The Variant rotation: clockwise quarter turns about the block centre, x then y then z.
     MOVE 0 TO ME-ROT-KIND(1)
     MOVE DIR-UP TO WS-FACE
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE WS-SPRITE QUAD
     MOVE DIR-UP TO QD-CULL QD-SHADE
     MOVE 90 TO WS-X WS-Y
     MOVE 0 TO WS-Z
     CALL "VARIANT-ROTATE" USING QUAD WS-X WS-Y WS-Z
     MOVE "models Variant rotation x 90, y 90 turns the up face to east (cull and shade too)"
         TO TL-CASE
     PERFORM SHOW-CORNER
     MOVE QD-CULL TO WS-N
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-N DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE QD-SHADE TO WS-N
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-N DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "(1.000 0.000 0.000)  6  6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-X WS-Y
     MOVE 90 TO WS-Z
     MOVE DIR-NORTH TO QD-CULL
     MOVE DIR-DOWN TO QD-SHADE
     CALL "VARIANT-ROTATE" USING QUAD WS-X WS-Y WS-Z
     MOVE "models Variant rotation z 90 turns down to west; north stays north" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = QD-CULL * 10 + QD-SHADE
     MOVE 35 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quads baked per block state from the built-in pack.
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE SPACES TO WS-COUNTS
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 18
         MOVE BM-QUAD-COUNT(WS-S) TO WS-N
         MOVE WS-N(2:1) TO WS-COUNTS(WS-S:1)
     END-PERFORM
     MOVE "models every block state but void bakes the six faces of its cube" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "066666666666666666" TO TL-EXPECTED
     MOVE WS-COUNTS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 6
         MOVE BM-QUAD(5, WS-Q) TO QUAD
         MOVE QD-CULL TO WS-N
         STRING FUNCTION TRIM(TL-OBSERVED) WS-N "=" FUNCTION TRIM(AT-NAME(QD-SPRITE)) " "
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "models turf: the top face draws turf_top, the bottom loam, the sides turf_side, each "
         & "culled by its own neighbour" TO TL-CASE
     MOVE "1=cobolcraft:block/loam 2=cobolcraft:block/turf_top 3=cobolcraft:block/turf_side "
         & "4=cobolcraft:block/turf_side 5=cobolcraft:block/turf_side 6=cobolcraft:block/turf_side"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 6
         MOVE BM-QUAD(8, WS-Q) TO QUAD
         IF AT-NAME(QD-SPRITE) = "cobolcraft:block/cardstack_end"
             MOVE QD-CULL TO WS-N
             STRING FUNCTION TRIM(TL-OBSERVED) WS-N DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE "models cardstack axis=x: the end texture is on the west and east faces" TO TL-CASE
     MOVE "5 6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO SX-COUNT
     MOVE 3 TO WS-S
     CALL "STATE-BAKE" USING CLIENT-STATE WS-S STATE-MODELS
     MOVE BM-QUAD(3, 2) TO QUAD
     MOVE "models a state without a model gets the missing model: six faces, missing texture, "
         & "culled by their own neighbours" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6122 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BM-QUAD-COUNT(3) * 1000 + QD-SPRITE * 100 + QD-CULL * 10 + QD-SHADE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO SX-COUNT
     MOVE "cobolcraft:block/nothing" TO SX-ID(1)
     MOVE 0 TO SX-X(1) SX-Y(1) SX-Z(1)
     CALL "STATE-BAKE" USING CLIENT-STATE WS-S STATE-MODELS
     MOVE BM-QUAD(3, 6) TO QUAD
     MOVE "models a state whose model names no file gets the missing model" TO TL-CASE
     MOVE 6166 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BM-QUAD-COUNT(3) * 1000 + QD-SPRITE * 100 + QD-CULL * 10 + QD-SHADE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-QUAD.
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         STRING "(" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         COMPUTE WS-E ROUNDED = QD-X(WS-K)
         STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         COMPUTE WS-E ROUNDED = QD-Y(WS-K)
         STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         COMPUTE WS-E ROUNDED = QD-Z(WS-K)
         STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         MOVE QD-U(WS-K) TO WS-N
         STRING FUNCTION TRIM(WS-N) ".000 " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
         MOVE QD-V(WS-K) TO WS-N
         STRING FUNCTION TRIM(WS-N) ".000)" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE WS-OUT TO TL-OBSERVED.

 SHOW-CORNER.
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     STRING "(" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = QD-X(1)
     STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = QD-Y(1)
     STRING FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = QD-Z(1)
     STRING FUNCTION TRIM(WS-E) ")" DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE "T" TO TL-MODE
     MOVE WS-OUT TO TL-OBSERVED.
 END PROGRAM TEST-MODELS.
