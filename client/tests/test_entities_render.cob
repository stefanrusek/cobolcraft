*> Implementation test of client/src/entities-render.cob (ENTITY-ATLAS-BUILD, ENTITIES-MESH): with
*> no pack supplying the entity textures the entity atlas holds the missing-texture stripes at
*> each stand-in size (standin-content §1.4.2: "for a texture of another size the same formula"):
*> operator 66 x 28 at row 0, sodgrazer 80 x 23 at row 28, abend 72 x 12 at row 51 of an 80 x 63
*> atlas, built again without leaking the old image; a loose_item has no boxes and draws nothing;
*> an operator in a dark cell is shaded no darker than 0.1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITIES-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-STRIPES             PIC X(7392).
 01 WS-SOD-STRIPES         PIC X(7360).
 01 WS-ABEND-STRIPES       PIC X(3456).
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EB                  PIC 9.99.
 01 WS-EDIT                PIC Z9.
 01 B-ATLAS                PIC X(20160) BASED.
 01 WS-VT-LAYER            PIC XX VALUE "EN".
 01 WS-VT-OK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 66 TO WS-W
     MOVE 28 TO WS-H
     CALL "MISSING-TEXTURE" USING WS-W WS-H WS-STRIPES
     MOVE 80 TO WS-W
     MOVE 23 TO WS-H
     CALL "MISSING-TEXTURE" USING WS-W WS-H WS-SOD-STRIPES
     MOVE 72 TO WS-W
     MOVE 12 TO WS-H
     CALL "MISSING-TEXTURE" USING WS-W WS-H WS-ABEND-STRIPES
     MOVE 0 TO WS-ROWS
     IF EA-W = 80 AND EA-H = 63
         SET ADDRESS OF B-ATLAS TO EA-ADDR
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 27
             IF B-ATLAS(WS-R * 320 + 1:264) = WS-STRIPES(WS-R * 264 + 1:264)
                 ADD 1 TO WS-ROWS
             END-IF
         END-PERFORM
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 22
             IF B-ATLAS((28 + WS-R) * 320 + 1:320) = WS-SOD-STRIPES(WS-R * 320 + 1:320)
                 ADD 1 TO WS-ROWS
             END-IF
         END-PERFORM
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 11
             IF B-ATLAS((51 + WS-R) * 320 + 1:288) = WS-ABEND-STRIPES(WS-R * 288 + 1:288)
                 ADD 1 TO WS-ROWS
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-ROWS TO WS-EDIT
     MOVE "entities render with no pack supplying the entity textures the 80 x 63 entity atlas "
         & "holds the missing texture at 66 x 28, 80 x 23 and 72 x 12 (63 rows), marked for upload"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "rows 63 upload 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "rows " FUNCTION TRIM(WS-EDIT) " upload " AT-UPLOAD(2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A loose_item and an operator; the operator stands in a dark cell (night, no sky light).
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 256 TO PL-HEIGHT
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-loose-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entities render a loose_item has no entity boxes (it is a ground item) and draws "
         & "nothing in the entity mesh" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO SK-U
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entities render an operator in the dark is shaded 0.1 (the floor), 36 vertices"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "36 0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EB ROUNDED = RL-EN-B(1)
     MOVE SPACES TO TL-OBSERVED
     IF RL-EN-COUNT = 36
         MOVE "36" TO TL-OBSERVED
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-EB DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-VERTEX-TINTS" USING CLIENT-STATE WS-VT-LAYER WS-VT-OK
     MOVE "tint channel every vertex of the entity figures is untinted white (1, 1, 1) and has no sky term"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VT-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITIES-RENDER.
 COPY CLTEST.
