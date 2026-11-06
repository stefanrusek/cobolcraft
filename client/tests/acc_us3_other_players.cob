*> Acceptance test of US3-5, the client half (standin-content §3.1, §3.2 operator figure; 08 §10.3,
*> §10.11; client/src/entities-replica.cob, entities-render.cob): an operator entity added by the
*> server is drawn as the 11 x 28 x 11 box with the operator texture (texture 1) at its position,
*> its front (+z in model space, the texture's front rectangle) toward its yaw; it follows a
*> teleport and disappears when removed (its mesh slot released). The built-in operator texture
*> equals the reference operator.rgba pixel for pixel (SC-004).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-OTHER-PLAYERS.
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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG VALUE 78.
 01 WS-IMAGE               PIC X(65536).
 01 WS-REFERENCE           PIC X(65536).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 65536.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
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
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
*>   Faces relative to the eye (0.5, 55.6, 0.5); the entity at (4.5, 54, 8.5) faces +X (yaw -90).
     MOVE SPACES TO WS-TEXT
     MOVE "front  4.34375 -0.725  8.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "back   3.65625 -0.725  8.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "top    4.0      0.15   8.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-ENTITY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US3-5 client half: given an operator entity at (4.5, 54, 8.5) with yaw -90 "
         & "then it is drawn on texture 1 as the standin §3 box: front (u 0) on its +X side, back "
         & "(u 11/66) on its -X side, top (u 44/66) above" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "front 0.0000/0.0000 0.80 back 0.1667/0.0000 0.80 top 0.6667/0.0000 1.00 36 1 0"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-80-teleport-entity.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "front  100.34375 15.275 -21.0" TO WS-SPEC
     CALL "TEST-FIGURE-FACE" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "acceptance US3-5 client half: when the entity is teleported to (100.5, 70, -20.5) then "
         & "the figure is drawn there" TO TL-CASE
     MOVE "front 0.0000/0.0000 0.80" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-ENTITY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US3-5 client half: when the entity is removed then no figure is drawn and "
         & "the entity mesh slot is released" TO TL-CASE
     MOVE "0 0 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/entity/operator.png" TO WS-PATH
     MOVE 46 TO WS-PATH-LENGTH
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-IMAGE-CAP WS-W WS-H
         WS-FOUND
     MOVE "client/tests/fixtures/textures/operator.rgba" TO WS-PATH
     CALL "TEST-READ-FILE" USING WS-PATH WS-REFERENCE WS-IMAGE-CAP WS-LENGTH
     MOVE "acceptance US3-5 SC-004 given only the built-in pack when "
         & "assets/cobolcraft/textures/entity/operator.png is read then it is 66 x 28 and equals "
         & "the reference operator.rgba pixel for pixel" TO TL-CASE
     MOVE "found 66 x 28 equal" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-FOUND = 1 AND WS-W = 66 AND WS-H = 28 AND WS-LENGTH = 7392
         IF WS-IMAGE(1:7392) = WS-REFERENCE(1:7392)
             MOVE "found 66 x 28 equal" TO TL-OBSERVED
         ELSE
             MOVE "found 66 x 28 different" TO TL-OBSERVED
         END-IF
     ELSE
         MOVE "not found or another size" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-OTHER-PLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FIGURE-FACE.
*> USING CLIENT-STATE, spec (PIC X(40): label, then the eye-relative face centre x y z), text
*> (appended): " <label> <u>/<v> <brightness>" of the entity quad with that centre, or
*> " <label> none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LABEL               PIC X(8).
 01 WS-SX                  PIC X(12).
 01 WS-SY                  PIC X(12).
 01 WS-SZ                  PIC X(12).
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-ADDR                USAGE POINTER.
 01 WS-EU                  PIC 9.9(4).
 01 WS-EV                  PIC 9.9(4).
 01 WS-EB                  PIC 9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SPEC                 PIC X(40).
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-SPEC L-TEXT.
     MOVE SPACES TO WS-LABEL WS-SX WS-SY WS-SZ
     UNSTRING L-SPEC DELIMITED BY ALL SPACE INTO WS-LABEL WS-SX WS-SY WS-SZ
     COMPUTE WS-X = FUNCTION NUMVAL(WS-SX)
     COMPUTE WS-Y = FUNCTION NUMVAL(WS-SY)
     COMPUTE WS-Z = FUNCTION NUMVAL(WS-SZ)
     SET WS-ADDR TO ADDRESS OF RL-EN-VERTEX(1)
     CALL "TEST-MESH-FACE" USING WS-ADDR RL-EN-COUNT WS-X WS-Y WS-Z WS-FOUND WS-B WS-U WS-V
     IF WS-FOUND = 1
         COMPUTE WS-EU ROUNDED = WS-U
         COMPUTE WS-EV ROUNDED = WS-V
         COMPUTE WS-EB ROUNDED = WS-B
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " " WS-EU "/" WS-EV " " WS-EB
             DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " none" DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-FIGURE-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-DRAWS.
*> USING CLIENT-STATE, text (appended): " <entity vertices> <draws on texture 1> <empty uploads of
*> the entity slot>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-RELEASED            BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-EDIT2               PIC Z(4)9.
 01 WS-EDIT3               PIC Z(4)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE 0 TO WS-DRAWS WS-RELEASED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-TEX(WS-I) = CC-TEX-ENTITIES AND RL-D-SLOT(WS-I) = MESH-SLOT-ENTITIES
             ADD 1 TO WS-DRAWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-ENTITIES AND RL-U-COUNT(WS-I) = 0
             ADD 1 TO WS-RELEASED
         END-IF
     END-PERFORM
     MOVE RL-EN-COUNT TO WS-EDIT
     MOVE WS-DRAWS TO WS-EDIT2
     MOVE WS-RELEASED TO WS-EDIT3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-ENTITY-DRAWS.
 COPY CLTEST.
