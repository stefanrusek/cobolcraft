*> Acceptance test of US9-1, the client half (standin-content §3.1, §12.6 mob models and textures;
*> 08 §10.3, §10.11; client/src/entities-render.cob, packs/builtin.cob): a sodgrazer and an abend
*> added by the server are drawn on texture 1 as their §12.6 boxes (sodgrazer: body, head and four
*> legs; abend: one body) with the active pack's textures/entity/<mob>.png, at their positions and
*> turned to their yaw; a sodgrazer that moves and turns is drawn at its new place and facing. The
*> entity atlas stacks operator (66 x 28, y 0), sodgrazer (80 x 23, y 28) and abend (72 x 12, y 51),
*> 80 x 63 in all, so a face's v is (image top + strip row) / 63 and its u is the texel column / 80.
*> The built-in sodgrazer and abend textures equal their references pixel for pixel (SC-004).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-MOB-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-SPEC                PIC X(40).
 01 WS-SOD-IMAGE           PIC X(65536).
 01 WS-ABEND-IMAGE         PIC X(65536).
 01 WS-REFERENCE           PIC X(65536).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 65536.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-SOD-ROWS            BINARY-LONG.
 01 WS-ABEND-ROWS          BINARY-LONG.
 01 WS-EDIT                PIC Z9.
 01 WS-EDIT2               PIC Z9.
 01 B-ATLAS                PIC X(20160) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 256 TO PL-HEIGHT
     MOVE 1 TO PL-HAS-SKY
     MOVE 0.5 TO PL-X PL-Z
     MOVE 54 TO PL-Y
     MOVE 6000 TO PL-TIME
     CALL "SKY-UPDATE" USING CLIENT-STATE

*>   The sodgrazer at (12.5, 56, 3.5) facing -X (yaw 90): model +z (front) is world -X, model +x
*>   is world +Z. Face centres relative to the eye (0.5, 55.6, 0.5).
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "front  11.625   0.86875 3.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "back   12.375   0.86875 3.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "top    12.0     1.15    3.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "head   11.3125  1.025   3.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "leg    11.6875  0.49375 3.21875" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-ENTITY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US9-1 client half: given a sodgrazer at (12.5, 56, 3.5) yaw 90 then it is "
         & "drawn on texture 1 as its §12.6 boxes with sodgrazer.png: body, head and leg fronts "
         & "toward -X, back and top as §3.1 lays them out, 6 boxes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "front 0.0000/0.4444 0.80 back 0.1750/0.4444 0.80 top 0.6500/0.4444 1.00 head "
         & "0.0000/0.6349 0.80 leg 0.0000/0.7619 0.80 216 1 0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The abend at (-3.5, 52, -6.5) facing -Z (yaw -180).
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-abend.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "front  -4.0    -3.225  -7.375" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "top    -4.0    -2.85   -7.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-ENTITY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US9-1 client half: given an abend at (-3.5, 52, -6.5) with yaw -180 then "
         & "it is drawn as its 12 x 12 x 12 box with abend.png: front (u 0, v 51/63) on its -Z "
         & "side, top (u 48/80) above; with the sodgrazer 7 boxes" TO TL-CASE
     MOVE "front 0.0000/0.8095 0.80 top 0.6000/0.8095 1.00 252 1 0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sodgrazer moves to (12.5625, 56, 3.4375) and turns to yaw -180 (facing -Z).
     MOVE "contract/fixtures/wire/play-s2c-36-move-entity-pos.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-37-move-entity-pos-rot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "front  12.0625  0.86875 2.5625" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "head   12.0625  1.025   2.25" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "acceptance US9-1 client half: when the sodgrazer moves to (12.5625, 56, 3.4375) and "
         & "turns to yaw -180 then its body and head fronts are drawn there toward -Z" TO TL-CASE
     MOVE "front 0.0000/0.4444 0.80 head 0.0000/0.6349 0.80" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The active pack's images, and the atlas rectangles the faces sample.
     MOVE "assets/cobolcraft/textures/entity/sodgrazer.png" TO WS-PATH
     MOVE 47 TO WS-PATH-LENGTH
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-SOD-IMAGE WS-IMAGE-CAP WS-W
         WS-H WS-FOUND
     MOVE "client/tests/fixtures/textures/sodgrazer.rgba" TO WS-PATH
     CALL "TEST-READ-FILE" USING WS-PATH WS-REFERENCE WS-IMAGE-CAP WS-LENGTH
     MOVE "SC-004 given only the built-in pack when "
         & "assets/cobolcraft/textures/entity/sodgrazer.png is read then it is 80 x 23 and equals "
         & "the reference sodgrazer.rgba pixel for pixel" TO TL-CASE
     MOVE "found 80 x 23 equal" TO TL-EXPECTED
     MOVE "not found or another size" TO TL-OBSERVED
     IF WS-FOUND = 1 AND WS-W = 80 AND WS-H = 23 AND WS-LENGTH = 7360
         MOVE "found 80 x 23 different" TO TL-OBSERVED
         IF WS-SOD-IMAGE(1:7360) = WS-REFERENCE(1:7360)
             MOVE "found 80 x 23 equal" TO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/entity/abend.png" TO WS-PATH
     MOVE 43 TO WS-PATH-LENGTH
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-ABEND-IMAGE WS-IMAGE-CAP
         WS-W WS-H WS-FOUND
     MOVE "client/tests/fixtures/textures/abend.rgba" TO WS-PATH
     CALL "TEST-READ-FILE" USING WS-PATH WS-REFERENCE WS-IMAGE-CAP WS-LENGTH
     MOVE "SC-004 given only the built-in pack when assets/cobolcraft/textures/entity/abend.png "
         & "is read then it is 72 x 12 and equals the reference abend.rgba pixel for pixel"
         TO TL-CASE
     MOVE "found 72 x 12 equal" TO TL-EXPECTED
     MOVE "not found or another size" TO TL-OBSERVED
     IF WS-FOUND = 1 AND WS-W = 72 AND WS-H = 12 AND WS-LENGTH = 3456
         MOVE "found 72 x 12 different" TO TL-OBSERVED
         IF WS-ABEND-IMAGE(1:3456) = WS-REFERENCE(1:3456)
             MOVE "found 72 x 12 equal" TO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-SOD-ROWS WS-ABEND-ROWS
     IF EA-W = 80 AND EA-H = 63
         SET ADDRESS OF B-ATLAS TO EA-ADDR
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 22
             IF B-ATLAS((28 + WS-R) * 320 + 1:320) = WS-SOD-IMAGE(WS-R * 320 + 1:320)
                 ADD 1 TO WS-SOD-ROWS
             END-IF
         END-PERFORM
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 11
             IF B-ATLAS((51 + WS-R) * 320 + 1:288) = WS-ABEND-IMAGE(WS-R * 288 + 1:288)
                 ADD 1 TO WS-ABEND-ROWS
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-SOD-ROWS TO WS-EDIT
     MOVE WS-ABEND-ROWS TO WS-EDIT2
     MOVE "acceptance US9-1 client half: the entity atlas (texture 1) holds the active pack's "
         & "sodgrazer.png at rows 28 to 50 and abend.png at rows 51 to 62 of its 80 x 63" TO TL-CASE
     MOVE "sodgrazer rows 23 abend rows 12" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "sodgrazer rows " FUNCTION TRIM(WS-EDIT) " abend rows " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US9-MOB-RENDER.
 COPY CLTEST.
