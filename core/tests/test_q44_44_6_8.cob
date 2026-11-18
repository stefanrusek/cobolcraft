*> Strider (docs/protocol/44-residual-mob-questions-6-nether.md section 8.2; lane 002-lane-p49c, T15502): a strider is suffocating (cold) unless the block at its position
*> or the block it stands on is lava, or lava is at its position; ridingWarm (a strider whose vehicle is a strider that is not suffocating) keeps a rider strider warm
*> (suffocating = not warm and not ridingWarm).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-LAVA-STATE          BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 14.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:strider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 7
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 7
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
*>   One lava cell in the floor at (X0 + 4, FY, Z0 + 4).
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA-STATE
     COMPUTE WS-LX = WS-X0 + 4
     COMPUTE WS-LZ = WS-Z0 + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-LX WS-FY WS-LZ WS-LAVA-STATE
*>   A strider on the lava cell (feet in it) is warm; one on stone is cold; a baby on the cold one is cold.
     COMPUTE WS-X = WS-LX + 0.5
     COMPUTE WS-Y = WS-FY + 0.5
     COMPUTE WS-Z = WS-LZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = WS-X0 + 1.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-B
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-C
     CALL "STRIDER-COLD" USING WS-A
     CALL "STRIDER-COLD" USING WS-B
     MOVE "acceptance US15 44-6§8.2 a strider in lava is warm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§8.2 a strider on stone is suffocating" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   C rides the warm strider A: ridingWarm, so it is not suffocating although it stands on no lava.
     MOVE WS-A TO EN-MOUNT(WS-C)
     MOVE EN-ID(WS-A) TO EN-MOUNT-ID(WS-C)
     CALL "STRIDER-COLD" USING WS-C
     MOVE "acceptance US15 44-6§8.2 ridingWarm: a strider riding a warm strider is not suffocating" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Riding the cold strider B gives no warmth.
     MOVE WS-B TO EN-MOUNT(WS-C)
     MOVE EN-ID(WS-B) TO EN-MOUNT-ID(WS-C)
     CALL "STRIDER-COLD" USING WS-C
     MOVE "acceptance US15 44-6§8.2 riding a suffocating strider gives no warmth" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-8.
 COPY CORETEST.
 COPY MOBSPTEST.
