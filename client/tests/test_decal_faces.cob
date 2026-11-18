*> Implementation test of the baked positions of flat decal elements (operator play: pink petals, glow lichen, leaf
*> litter, vines, sculk veins and resin clumps flicker). A decal is an element of no thickness along one axis
*> with a face on both sides (glow_lichen: from [0,0,0.1] to [16,16,0.1] with a north and a south face; the petal
*> pads: up and down at y 2.99). The two quads of one element lay in one plane; the opaque layer passes equal depth,
*> so the face that looks into the supporting block (lit 0 there) and the face that looks into the air fought for
*> the pixel. ELEMENT-BAKE now moves each of the two quads of such an element 0.002 of a block (0.032 pixels of the
*> model) out along its own normal, before the element rotation, so the viewer's side is nearer. 08 and 12 do not
*> name an offset for these (12 only gives the crumbling overlay a depth bias), so this is the bake's own choice.
*> Cases: lichen pair, petal pad pair, a rotated stem pair, a flat element with one face, and a full cube.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DECAL-FACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-TEXT                PIC X(512).
 01 WS-FACE-A              BINARY-LONG.
 01 WS-FACE-B              BINARY-LONG.
 01 WS-QA.
    05 WS-A-CORNER OCCURS 4 TIMES.
       10 WS-AX            COMP-2.
       10 WS-AY            COMP-2.
       10 WS-AZ            COMP-2.
 01 WS-QB.
    05 WS-B-CORNER OCCURS 4 TIMES.
       10 WS-BX            COMP-2.
       10 WS-BY            COMP-2.
       10 WS-BZ            COMP-2.
 01 WS-D                   COMP-2.
 01 WS-DX                  COMP-2.
 01 WS-DZ                  COMP-2.
 01 WS-E1                  PIC -(3)9.9(6).
 01 WS-E2                  PIC -(3)9.9(6).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE

*>   Glow lichen: the north and the south face at z 0.1/16 move apart along z, each toward its own side.
     MOVE '{"elements":[{"from":[0,0,0.1],"to":[16,16,0.1],"faces":{"north":{"uv":[16,0,0,16],"texture":"#a"},'
         & '"south":{"uv":[0,0,16,16],"texture":"#a"}}}]}' TO WS-TEXT
     MOVE DIR-NORTH TO WS-FACE-A
     MOVE DIR-SOUTH TO WS-FACE-B
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-A WS-QA
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-B WS-QB
     COMPUTE WS-E1 ROUNDED = WS-AZ(1)
     COMPUTE WS-E2 ROUNDED = WS-BZ(1)
     MOVE "decal faces a lichen element's north quad lies 0.002 north of its plane and the south quad 0.002 south"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "north 0.004250 south 0.008250" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "north " FUNCTION TRIM(WS-E1) " south " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "decal faces the lichen quads keep their extent in the plane (x 0 to 1)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AX(1) > 0.9999 AND WS-AX(1) < 1.0001 AND WS-AX(2) < 0.0001 AND WS-BX(1) < 0.0001
             AND WS-BX(2) > 0.9999 AND WS-BX(2) < 1.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Petal pad: the up and the down face at y 2.99/16.
     MOVE '{"elements":[{"from":[0,2.99,0],"to":[8,2.99,8],"faces":{"up":{"uv":[0,0,8,8],"texture":"#a"},'
         & '"down":{"uv":[0,8,8,0],"texture":"#a"}}}]}' TO WS-TEXT
     MOVE DIR-UP TO WS-FACE-A
     MOVE DIR-DOWN TO WS-FACE-B
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-A WS-QA
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-B WS-QB
     COMPUTE WS-D = WS-AY(1) - WS-BY(1)
     MOVE "decal faces a petal pad's up quad is 0.004 above its down quad, both around y 2.99/16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D > 0.00399 AND WS-D < 0.00401 AND WS-AY(1) > 0.18 AND WS-AY(1) < 0.19
             AND WS-BY(1) > 0.18 AND WS-BY(1) < 0.19
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A stem pair turned 45 degrees: the quads end on the two sides of the turned plane, 0.004 apart.
     MOVE '{"elements":[{"from":[4.25,0,-2.6],"to":[4.25,2.99,-1.6],"rotation":{"angle":-45,"axis":"y",'
         & '"origin":[0,0,0]},"faces":{"east":{"uv":[0,4,1,7],"texture":"#a"},"west":{"uv":[0,4,1,7],"texture":"#a"}}}]}'
         TO WS-TEXT
     MOVE DIR-EAST TO WS-FACE-A
     MOVE DIR-WEST TO WS-FACE-B
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-A WS-QA
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-B WS-QB
     COMPUTE WS-DX = WS-AX(1) - WS-BX(1)
     COMPUTE WS-DZ = WS-AZ(1) - WS-BZ(1)
     *>   the distance along the plane's normal (cos 45, 0, sin 45); the corners differ in the plane too
     COMPUTE WS-D = (WS-DX + WS-DZ) * 0.7071068
     MOVE "decal faces a stem element turned 45 degrees: its east and west quads are 0.004 apart" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D > 0.00399 AND WS-D < 0.00401
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A flat element with one face (a plane seen from one side) stays where the model puts it.
     MOVE '{"elements":[{"from":[0,0,8],"to":[16,16,8],"faces":{"north":{"uv":[16,0,0,16],"texture":"#a"}}}]}'
         TO WS-TEXT
     MOVE DIR-NORTH TO WS-FACE-A
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-A WS-QA
     MOVE "decal faces a flat element with a single face is not moved (z 0.5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AZ(1) = 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cube is untouched: its north face is at z 0 and its south face at z 1 exactly.
     MOVE '{"elements":[{"from":[0,0,0],"to":[16,16,16],"faces":{"north":{"texture":"#a"},"south":{"texture":"#a"}}}]}'
         TO WS-TEXT
     MOVE DIR-NORTH TO WS-FACE-A
     MOVE DIR-SOUTH TO WS-FACE-B
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-A WS-QA
     CALL "DECAL-BAKE" USING WS-TEXT WS-FACE-B WS-QB
     MOVE "decal faces a full cube's north face is at z 0 and its south face at z 1, unmoved" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AZ(1) = 0 AND WS-BZ(1) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DECAL-FACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECAL-BAKE.
*> USING model text (a model JSON with one element), face (DIR-*), corners out (x, y, z of the four corners,
*> COMP-2 each): parses the first element and bakes the face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY JSONDOC.
 COPY CLMODEL.
 COPY CLQUAD.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SPRITE              BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(8) VALUE "elements".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 8.
 01 WS-NODE                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(512).
 01 L-FACE                 BINARY-LONG.
 01 L-OUT.
    05 L-CORNER OCCURS 4 TIMES.
       10 L-X              COMP-2.
       10 L-Y              COMP-2.
       10 L-Z              COMP-2.
 PROCEDURE DIVISION USING L-TEXT L-FACE L-OUT.
     INITIALIZE MODEL-RESOLVED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-TEXT)) TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT WS-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE JN-FIRST(WS-NODE) TO WS-NODE
     CALL "MODEL-ELEMENT-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED WS-ONE
     MOVE 1 TO MR-ELEMENT-COUNT
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE L-FACE WS-SPRITE QUAD
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
         MOVE QD-X(WS-C) TO L-X(WS-C)
         MOVE QD-Y(WS-C) TO L-Y(WS-C)
         MOVE QD-Z(WS-C) TO L-Z(WS-C)
     END-PERFORM
     GOBACK.
 END PROGRAM DECAL-BAKE.
 COPY CLTEST.
