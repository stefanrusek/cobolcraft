*> Acceptance test, villager panic from hostiles (docs/protocol/44 sections 2.14 and 4.2; lane 002-lane-mobsb5, T8905): the villager_hostiles distances, the panic start, the calm-down
*> distance of 6 blocks, dead and unlisted mobs ignored.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-FEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-V
     MOVE 40 TO CW-TICKS
*>   A zombie 9 blocks away is beyond its 8 block distance.
     COMPUTE WS-X = WS-X0 + 9
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z0 WS-YAW WS-Z
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§4.2 a zombie at 9 blocks does not scare" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   At 7 blocks it does; the villager flees from the zombie's position.
     COMPUTE EN-X(WS-Z) = WS-X0 + 7
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§2.14 a zombie at 7 blocks starts the panic (21 ticks)" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§2.14 it flees from the zombie's position" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(WS-X0 + 7)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-FLEE-X(WS-V))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   While panicking, a hostile beyond 6 blocks does not extend the panic.
     MOVE 5 TO EN-FLEE(WS-V)
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§2.14 beyond 6 blocks the panic is not extended" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-Z) = WS-X0 + 5
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§2.14 within 6 blocks the panic is extended" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Off the 20 tick beat nothing is scanned.
     MOVE 0 TO EN-FLEE(WS-V)
     MOVE 41 TO CW-TICKS
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§2.18 the sensor runs on the 20 tick beat only" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO CW-TICKS
*>   A dead zombie does not scare.
     MOVE 0 TO EN-HEALTH(WS-Z)
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§4.2 a dead zombie is ignored" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A cow is not a hostile; a pillager scares from 14 blocks (limit 15).
     COMPUTE WS-X = WS-X0 + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-CTYPE WS-X WS-Y WS-Z0 WS-YAW WS-Z
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§4.2 a cow is not a hostile" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 + 14
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z0 WS-YAW WS-Z
     CALL "VL-FEAR-STEP" USING WS-V
     MOVE "acceptance US15 44§4.2 a pillager scares from 14 blocks" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-FEAR.

 COPY CORETEST.
 COPY MOBSPTEST.
