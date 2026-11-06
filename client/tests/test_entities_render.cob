*> Implementation test of client/src/entities-render.cob (ENTITY-ATLAS-BUILD, ENTITIES-MESH): with
*> no pack supplying textures/entity/operator.png the entity atlas holds the missing-texture
*> stripes at the stand-in size 66 x 28 (standin-content §1.4.2: "for a texture of another size
*> the same formula"), built again without leaking the old image; an entity that is not an
*> operator draws nothing yet; an operator in a dark cell is shaded no darker than 0.1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITIES-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-W                   BINARY-LONG VALUE 66.
 01 WS-H                   BINARY-LONG VALUE 28.
 01 WS-STRIPES             PIC X(7392).
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EB                  PIC 9.99.
 01 B-ATLAS                PIC X(7392) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "MISSING-TEXTURE" USING WS-W WS-H WS-STRIPES
     SET ADDRESS OF B-ATLAS TO EA-ADDR
     MOVE "entities render with no pack supplying the operator texture the entity atlas is the "
         & "missing texture at 66 x 28, marked for upload" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "66 28 stripes 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF EA-W = 66 AND EA-H = 28
         MOVE "66 28" TO TL-OBSERVED
     END-IF
     IF B-ATLAS = WS-STRIPES
         STRING FUNCTION TRIM(TL-OBSERVED) " stripes " AT-UPLOAD(2) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A sodgrazer and an operator; the operator stands in a dark cell (night, no sky light).
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 256 TO PL-HEIGHT
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entities render an entity that is not an operator draws nothing (in this version)"
         TO TL-CASE
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
     STOP RUN.
 END PROGRAM TEST-ENTITIES-RENDER.
 COPY CLTEST.
