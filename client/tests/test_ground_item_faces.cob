*> T32300 (lane 002-lane-bugitems, operator try14 13.33.53: the dropped dirt block showed its far and under faces over the near ones): the ground items mesh
*> is drawn without depth writes (CC-PIPE-TRANSLUCENT), so every quad of a cube is painted in the order it is in the vertex buffer and a face the camera cannot see
*> (it lies on the far side of the cube) covers the faces it can. The mesh of a dropped block item therefore holds only the faces that face the camera: for the
*> real dirt item at (10.5, 64, 10.5) and four eye positions the emitted faces are the ones computed by the independent script
*> client/tests/fixtures/gen_item_faces.py (n . (eye - centre) > 0.125), 6 vertices each, and every emitted triangle is clockwise seen from outside
*> (cross(v2 - v1, v3 - v2) . (v1 - eye) > 0, the winding of the terrain). The generated vanilla pack is read from CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-FACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-CASE                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-QUADS               BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-LETTERS             PIC X(6).
 01 WS-SEEN                PIC X(6).
 01 WS-FLAGS               PIC X(6).
 01 WS-ALL                 PIC X(6) VALUE "DENSUW".
 01 WS-SET                 PIC X(6).
 01 WS-POS                 BINARY-LONG.
 01 WS-CX                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DV                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-B                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CROSS               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-EYE-DATA.
    05 FILLER              PIC X(12) VALUE "105 660 085 ".
    05 FILLER              PIC X(12) VALUE "120 650 120 ".
    05 FILLER              PIC X(12) VALUE "090 630 090 ".
    05 FILLER              PIC X(12) VALUE "100 640 100 ".
 01 WS-EYE-TABLE-DATA REDEFINES WS-EYE-DATA.
    05 WS-EYE-ROW          OCCURS 4 TIMES.
       10 WS-EYE-X         PIC 999.
       10 FILLER           PIC X.
       10 WS-EYE-Y         PIC 999.
       10 FILLER           PIC X.
       10 WS-EYE-Z         PIC 999.
       10 FILLER           PIC X.
 01 WS-EXPECT-DATA.
    05 FILLER              PIC X(6) VALUE "NU    ".
    05 FILLER              PIC X(6) VALUE "ESU   ".
    05 FILLER              PIC X(6) VALUE "DNW   ".
    05 FILLER              PIC X(6) VALUE "DNW   ".
 01 WS-EXPECT-TABLE REDEFINES WS-EXPECT-DATA.
    05 WS-EXPECT           PIC X(6) OCCURS 4 TIMES.
 01 WS-EYE-POINT.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE SPACES TO WS-KEY
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 64 TO WS-ID
     MOVE 10.5 TO WS-X WS-Z
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-YAW
     CALL "GIF-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE WS-ITEM TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     MOVE 0 TO CL-NOW-MS
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 4
         COMPUTE WS-EYE(1) = WS-EYE-X(WS-CASE) / 10
         COMPUTE WS-EYE(2) = WS-EYE-Y(WS-CASE) / 10
         COMPUTE WS-EYE(3) = WS-EYE-Z(WS-CASE) / 10
         MOVE 0 TO RL-GI-COUNT
         CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
*>       The cube's centre from the eye: entity (10.5, 64, 10.5) + (0, 0.2875, 0) - eye.
         COMPUTE WS-CX(1) = 10.5 - WS-EYE(1)
         COMPUTE WS-CX(2) = 64.2875 - WS-EYE(2)
         COMPUTE WS-CX(3) = 10.5 - WS-EYE(3)
         MOVE SPACES TO WS-FLAGS WS-SEEN
         MOVE 0 TO WS-FRONT
         COMPUTE WS-QUADS = RL-GI-COUNT / 6
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-QUADS
             COMPUTE WS-BASE = (WS-Q - 1) * 6
*>           The face by the quad's centroid relative to the cube's centre: the axis of the largest difference and its sign.
             MOVE 0 TO WS-DV(1) WS-DV(2) WS-DV(3)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 COMPUTE WS-DV(1) = WS-DV(1) + RL-GI-X(WS-BASE + WS-K) / 6
                 COMPUTE WS-DV(2) = WS-DV(2) + RL-GI-Y(WS-BASE + WS-K) / 6
                 COMPUTE WS-DV(3) = WS-DV(3) + RL-GI-Z(WS-BASE + WS-K) / 6
             END-PERFORM
             PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
                 COMPUTE WS-DV(WS-AXIS) = WS-DV(WS-AXIS) - WS-CX(WS-AXIS)
             END-PERFORM
             MOVE 1 TO WS-AXIS
             MOVE FUNCTION ABS(WS-DV(1)) TO WS-BEST
             IF FUNCTION ABS(WS-DV(2)) > WS-BEST
                 MOVE 2 TO WS-AXIS
                 MOVE FUNCTION ABS(WS-DV(2)) TO WS-BEST
             END-IF
             IF FUNCTION ABS(WS-DV(3)) > WS-BEST
                 MOVE 3 TO WS-AXIS
             END-IF
             EVALUATE TRUE
                 WHEN WS-AXIS = 1 AND WS-DV(1) > 0
                     MOVE "E" TO WS-LETTERS(1:1)
                 WHEN WS-AXIS = 1
                     MOVE "W" TO WS-LETTERS(1:1)
                 WHEN WS-AXIS = 2 AND WS-DV(2) > 0
                     MOVE "U" TO WS-LETTERS(1:1)
                 WHEN WS-AXIS = 2
                     MOVE "D" TO WS-LETTERS(1:1)
                 WHEN WS-AXIS = 3 AND WS-DV(3) > 0
                     MOVE "S" TO WS-LETTERS(1:1)
                 WHEN OTHER
                     MOVE "N" TO WS-LETTERS(1:1)
             END-EVALUATE
             MOVE 0 TO WS-POS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 IF WS-ALL(WS-K:1) = WS-LETTERS(1:1)
                     MOVE WS-K TO WS-POS
                 END-IF
             END-PERFORM
             MOVE WS-LETTERS(1:1) TO WS-FLAGS(WS-POS:1)
*>           The first triangle (vertices 1 to 3) is clockwise seen from outside, so seen from the eye: cross(v2 - v1, v3 - v2) . v1 > 0.
             PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
                 EVALUATE WS-AXIS
                     WHEN 1
                         COMPUTE WS-A(1) = RL-GI-X(WS-BASE + 2) - RL-GI-X(WS-BASE + 1)
                         COMPUTE WS-B(1) = RL-GI-X(WS-BASE + 3) - RL-GI-X(WS-BASE + 2)
                     WHEN 2
                         COMPUTE WS-A(2) = RL-GI-Y(WS-BASE + 2) - RL-GI-Y(WS-BASE + 1)
                         COMPUTE WS-B(2) = RL-GI-Y(WS-BASE + 3) - RL-GI-Y(WS-BASE + 2)
                     WHEN OTHER
                         COMPUTE WS-A(3) = RL-GI-Z(WS-BASE + 2) - RL-GI-Z(WS-BASE + 1)
                         COMPUTE WS-B(3) = RL-GI-Z(WS-BASE + 3) - RL-GI-Z(WS-BASE + 2)
                 END-EVALUATE
             END-PERFORM
             COMPUTE WS-CROSS(1) = WS-A(2) * WS-B(3) - WS-A(3) * WS-B(2)
             COMPUTE WS-CROSS(2) = WS-A(3) * WS-B(1) - WS-A(1) * WS-B(3)
             COMPUTE WS-CROSS(3) = WS-A(1) * WS-B(2) - WS-A(2) * WS-B(1)
             COMPUTE WS-DOT = WS-CROSS(1) * RL-GI-X(WS-BASE + 1) + WS-CROSS(2) * RL-GI-Y(WS-BASE + 1)
                 + WS-CROSS(3) * RL-GI-Z(WS-BASE + 1)
             IF WS-DOT > 0
                 ADD 1 TO WS-FRONT
             END-IF
         END-PERFORM
         MOVE 0 TO WS-POS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-FLAGS(WS-K:1) NOT = SPACE
                 ADD 1 TO WS-POS
                 MOVE WS-FLAGS(WS-K:1) TO WS-SEEN(WS-POS:1)
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "T32300 dropped dirt, eye " WS-EYE-X(WS-CASE) " " WS-EYE-Y(WS-CASE) " " WS-EYE-Z(WS-CASE)
             " (tenths): only the faces that face the camera are in the mesh" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-EXPECT(WS-CASE) TO TL-EXPECTED
         MOVE WS-SEEN TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "T32300 dropped dirt, eye " WS-EYE-X(WS-CASE) " " WS-EYE-Y(WS-CASE) " " WS-EYE-Z(WS-CASE)
             " (tenths): every emitted triangle is clockwise seen from outside and faces the eye" DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-QUADS TO TL-EXPECTED-N
         MOVE WS-FRONT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-GROUND-ITEM-FACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIF-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM GIF-SPAWN.


 COPY CLTEST.
