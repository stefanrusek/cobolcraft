*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 7 and 9.3 through the renderer: thrown items and the firework rocket are one quad of the carried item's flat model facing the camera (scale of the type: fireball 3,
*> small fireball 0.75, the rest 1; a rocket shot at an angle rotated X 90, Y 180, Z 180), the ominous item spawner draws renderedAmount flat copies spun by wrapDegrees(age x 40) and grown over 50 ticks; extents computed by gen/rt9.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-THROWN-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 7.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-FIRST               BINARY-LONG VALUE 1.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-FIRST
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "snowball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "snowball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "snowball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 snowball shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "egg" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "egg" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "egg" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 egg shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ender_pearl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ender_pearl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ender_pearl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 ender_pearl shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "splash_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "splash_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "splash_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 splash_potion shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "lingering_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "lingering_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "lingering_potion" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 lingering_potion shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "experience_bottle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "experience_bottle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "experience_bottle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 experience_bottle shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 eye_of_ender shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE -250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 1250 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -375 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 1125 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -375 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 1125 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE -250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 1250 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE -129 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 1129 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -375 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 1125 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 92 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 fireball shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 908 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "small_fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 313 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 688 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -94 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 281 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "small_fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -94 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 281 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 313 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 688 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "small_fireball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 343 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 657 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -94 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 281 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 398 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 small_fireball shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 602 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO PL-YAW
     MOVE 1 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 min x (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 max x (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 min y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 max y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 min z (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 0 max z (thousandths)" TO TL-CASE
     MOVE 875 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 90 TO PL-YAW
     MOVE 1 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 min x (thousandths)" TO TL-CASE
     MOVE 125 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 max x (thousandths)" TO TL-CASE
     MOVE 625 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 min y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 max y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 min z (thousandths)" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 90 max z (thousandths)" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 0 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 290 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 710 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 375 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 364 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 0 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "firework_rocket" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 40 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 33 TO PL-YAW
     MOVE 1 TO EN-X1(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 min x (thousandths)" TO TL-CASE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 max x (thousandths)" TO TL-CASE
     MOVE 778 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 min y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 max y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 min z (thousandths)" TO TL-CASE
     MOVE 259 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§7 firework_rocket shot at angle 1 camera yaw 33 max z (thousandths)" TO TL-CASE
     MOVE 951 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "snowball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 41 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance US15 34-9§7 a thrown item without a stack draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 42 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 0 TO CL-NOW-MS
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 min x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 max x (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 min y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 max y (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 min z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 0.0 max z (thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 42 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 1250 TO CL-NOW-MS
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 min x (thousandths)" TO TL-CASE
     MOVE 478 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 max x (thousandths)" TO TL-CASE
     MOVE 522 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 min y (thousandths)" TO TL-CASE
     MOVE -62 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 max y (thousandths)" TO TL-CASE
     MOVE 188 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 min z (thousandths)" TO TL-CASE
     MOVE 377 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 1 age 25.0 max z (thousandths)" TO TL-CASE
     MOVE 623 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 42 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 5000 TO CL-NOW-MS
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 2 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 vertices" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 min x (thousandths)" TO TL-CASE
     MOVE 293 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 max x (thousandths)" TO TL-CASE
     MOVE 733 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 min y (thousandths)" TO TL-CASE
     MOVE -125 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 max y (thousandths)" TO TL-CASE
     MOVE 436 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 min z (thousandths)" TO TL-CASE
     MOVE 321 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 2 age 100.0 max z (thousandths)" TO TL-CASE
     MOVE 656 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 42 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 2500 TO CL-NOW-MS
     MOVE 9 TO EN-STACK-ITEM(1)
     MOVE 20 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 min x (thousandths)" TO TL-CASE
     MOVE 211 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 max x (thousandths)" TO TL-CASE
     MOVE 751 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 min y (thousandths)" TO TL-CASE
     MOVE -162 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 max y (thousandths)" TO TL-CASE
     MOVE 422 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 min z (thousandths)" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 20 age 50.0 max z (thousandths)" TO TL-CASE
     MOVE 630 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE SPACES TO WS-KEY
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 42 TO WS-ID
     MOVE 0 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE 12345 TO CL-NOW-MS
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 64 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-GI-COUNT TO WS-LAST
     CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 vertices" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 min x (thousandths)" TO TL-CASE
     MOVE 214 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 max x (thousandths)" TO TL-CASE
     MOVE 742 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 min y (thousandths)" TO TL-CASE
     MOVE -167 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 max y (thousandths)" TO TL-CASE
     MOVE 436 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 min z (thousandths)" TO TL-CASE
     MOVE 302 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 34-9§9 spawner stack 64 age 246.9 max z (thousandths)" TO TL-CASE
     MOVE 687 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-THROWN-9.
 COPY ENT9TEST.
 COPY CLTEST.
