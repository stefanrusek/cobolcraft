*> Implementation test (crash fix, 002-lane-crashfix; docs/design/world-types.md WT-22): the player and item entity roles of a
*> standard set are minecraft:player and minecraft:item, not the cobolcraft operator and loose_item keys, which the set does
*> not hold. A single-player standard world joined and then sent a Move Player packet crashed in MOVE-COLLIDES with the
*> entity type table subscript 0 (CR-OPERATOR was -1). The world is opened as cobolcraft (the fixture trees cannot give a
*> standard world), then the content set is replaced by the standard fixture set and the entity tables rebuilt.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STANDARD-ROLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PACKET              BINARY-LONG VALUE 30.
 01 WS-X                   FLOAT-LONG VALUE 5.25.
 01 WS-Y                   FLOAT-LONG VALUE 54.0.
 01 WS-Z                   FLOAT-LONG VALUE 8.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-EDIT-REAL           PIC -(6)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "content/tests/fixtures/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "ENTITIES-OPEN"

     MOVE "test standard roles: the player and item roles of a standard set are found (not -1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "found" TO TL-EXPECTED
     IF WS-STATUS = CT-OK AND CR-OPERATOR >= 0 AND CR-LOOSE-ITEM >= 0
         MOVE "found" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     CALL "TEST-MOVE" USING WS-CONN WS-PACKET WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     MOVE "test standard roles: a joined player's Move Player Pos in a standard world is accepted" TO TL-CASE
     MOVE PL-X(WS-ROW) TO WS-EDIT-REAL
     MOVE FUNCTION TRIM(WS-EDIT-REAL) TO TL-OBSERVED
     MOVE "5.25" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 END PROGRAM TEST-STANDARD-ROLES.
 COPY CORETEST.
