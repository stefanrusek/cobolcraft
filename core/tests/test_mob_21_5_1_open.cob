*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 5.1 with 44 part 6 section 9.1 and 44 part 8 section 6.3): the ghast's reflected fireball and its float point clamp. A large fireball
*> that a player deflected (the owner is the player) does 1000 damage to a ghast (not 6), and the kill is the player's; a fireball of the ghast itself does 6 to another mob. A float point whose column's
*> MOTION_BLOCKING height is below the point's Y and above the world's minimum Y is moved to (mob Y - |mob Y - point Y|): a point above the ghast is mirrored below it, a point at or below it stays,
*> and a column with no blocks is left alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-1-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-GHAST               BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DX                  FLOAT-LONG VALUE 1.
 01 WS-DY                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-POWER               BINARY-LONG VALUE 1.
 01 WS-OWNER               BINARY-LONG.
 01 WS-NOPLAYER            BINARY-LONG VALUE 0.
 01 WS-KIND-FIREBALL       BINARY-LONG VALUE 1.
 01 WS-MOBY                FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-NEWY                FLOAT-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-FARX                FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GHAST WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
*>   The explosion of a hit is put 60 blocks away so that only the hit's own damage shows.
     COMPUTE WS-FARX = WS-X + 60
*>   A fireball owned by a player hits a ghast: 1000 damage, the player is the killer.
     CALL "MOB-SPAWN" USING WS-DIM WS-GHAST WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PROJ-SPAWN" USING WS-KIND-FIREBALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-ROW WS-NOPLAYER WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.1 a reflected fireball (owner a player) does 1000 damage to a ghast: dead" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§5.1 and the player is the killer" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-KILLER(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A fireball owned by the ghast itself hits a pig: 6 damage as before.
     CALL "MOB-SPAWN" USING WS-DIM WS-GHAST WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG WS-X WS-Y WS-Z WS-YAW WS-OTHER
     CALL "PROJ-SPAWN" USING WS-KIND-FIREBALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER EN-ID(WS-ROW) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-OTHER WS-NOPLAYER WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.1 the ghast's own fireball hurts a pig for 6 (10 to 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-OTHER) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The float point clamp: the tank's column (x0 + 4, z0 + 4) is blocked up to the lid at y0 + 7, so its MOTION_BLOCKING height is y0 + 8.
     COMPUTE WS-PX = WS-X0 + 4.5
     COMPUTE WS-PZ = WS-Z0 + 4.5
     COMPUTE WS-MOBY = WS-Y0 + 30
     COMPUTE WS-PY = WS-Y0 + 40
     CALL "GHAST-CLAMP" USING WS-DIM WS-MOBY WS-PX WS-PY WS-PZ WS-NEWY
     MOVE "acceptance US15 44-6§9.1 a point above the ghast over a blocked column is mirrored below it (mob y0 + 30, point y0 + 40: y0 + 20)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 + 20
     COMPUTE TL-OBSERVED-N = WS-NEWY
     PERFORM CHECK-N
     COMPUTE WS-PY = WS-Y0 + 25
     CALL "GHAST-CLAMP" USING WS-DIM WS-MOBY WS-PX WS-PY WS-PZ WS-NEWY
     MOVE "acceptance US15 44-6§9.1 a point below the ghast stays (y0 + 25)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 + 25
     COMPUTE TL-OBSERVED-N = WS-NEWY
     PERFORM CHECK-N
     COMPUTE WS-PY = WS-Y0 + 5
     CALL "GHAST-CLAMP" USING WS-DIM WS-MOBY WS-PX WS-PY WS-PZ WS-NEWY
     MOVE "acceptance US15 44-6§9.1 a point inside the blocked column (height above the point) stays (y0 + 5)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 + 5
     COMPUTE TL-OBSERVED-N = WS-NEWY
     PERFORM CHECK-N
     COMPUTE WS-PX = 100000.5
     COMPUTE WS-PY = WS-Y0 + 40
     CALL "GHAST-CLAMP" USING WS-DIM WS-MOBY WS-PX WS-PY WS-PZ WS-NEWY
     MOVE "acceptance US15 44-6§9.1 a column without blocks (unloaded) is left alone (y0 + 40)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 + 40
     COMPUTE TL-OBSERVED-N = WS-NEWY
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-5-1-OPEN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
