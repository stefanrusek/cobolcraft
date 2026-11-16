*> Implementation test (lane 002-lane-mobsb; docs/protocol/19-mobs-land-friendly-and-neutral.md section 22): a spawned villager gets its state (plains, no profession, level 1), a removed one loses it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-VIL-LIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-PLAYER) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "VL-FIND" USING WS-ID WS-NO WS-SLOT
     MOVE "acceptance US15 19§22.1 a spawned villager has a state entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.1 it is a plains villager of level 1" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = VL-TYPE(WS-SLOT) * 10 + VL-LEVEL(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.1 it has 20 health" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "VL-FIND" USING WS-ID WS-NO WS-SLOT
     MOVE "acceptance US15 19§22 a removed villager loses its state" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-VIL-LIVE.
 COPY CORETEST.
 COPY MOBSPTEST.
