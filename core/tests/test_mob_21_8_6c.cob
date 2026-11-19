*> The base thunderHit of a lightning bolt (docs/protocol/44 part 9 section 2 and 2.1, 21 section 8.6.1; lane p49t, T39040): the fire counter rises by 1 and an entity whose counter was -1 (now 0) is set alight for
*> 8 seconds (160 ticks), then the 5.0 damage; players take the same counter rule.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-6C.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-COW                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 0.
 01 WS-PROW                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 30
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     ADD 20 TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
*>   Counter -1: now 0, so the 160-tick ignition.
     MOVE -1 TO EN-BURN(WS-COW)
     PERFORM STRIKE
     MOVE "acceptance US15 44-9§2.1 a cow at counter -1 struck by lightning burns for 160 ticks" TO TL-CASE
     MOVE 160 TO TL-EXPECTED-N
     MOVE EN-BURN(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Counter 0: now 1, no ignition.
     MOVE 0 TO EN-BURN(WS-COW)
     MOVE 20 TO EN-HEALTH(WS-COW)
     PERFORM STRIKE
     MOVE "acceptance US15 44-9§2.1 a cow at counter 0 gets counter 1 (no 8 second ignition)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BURN(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A survival player at counter -1 burns for 160 ticks; at 0 the counter becomes 1.
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE -1 TO EN-BURN(WS-PROW)
     PERFORM STRIKE
     MOVE "acceptance US15 44-9§2.1 a survival player at counter -1 struck by lightning burns for 160 ticks" TO TL-CASE
     MOVE 160 TO TL-EXPECTED-N
     MOVE EN-BURN(WS-PROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-BURN(WS-PROW)
     PERFORM STRIKE
     MOVE "acceptance US15 44-9§2.1 a survival player at counter 0 gets counter 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BURN(WS-PROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 STRIKE.
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VISUAL WS-ROW
     CALL "THROWN-TICK"
     CALL "PJ-DROP" USING WS-ROW.
 END PROGRAM TEST-MOB-21-8-6C.
 COPY CORETEST.
 COPY MOBSPTEST.
