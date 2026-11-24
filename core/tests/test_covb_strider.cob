*> Implementation test (lane covB; docs/protocol/21 section 5.7, 44-6 section 8): a strider outside lava finds the lava pool within 8 blocks by the timed scan and heads for it, and a rider
*> with an empty hand cannot steer it with a stick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-STRIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 14.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-LAVA-STATE          BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE "minecraft:strider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 7
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 7
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA-STATE
     PERFORM VARYING WS-FX FROM 4 BY 1 UNTIL WS-FX > 6
         PERFORM VARYING WS-FZ FROM 3 BY 1 UNTIL WS-FZ > 5
             COMPUTE WS-LX = WS-X0 + WS-FX
             COMPUTE WS-LZ = WS-Z0 + WS-FZ
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-LX WS-FY WS-LZ WS-LAVA-STATE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 1.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-S
*>   Over many ticks (the timed scan is 1 in 40 here) the strider out of lava picks the pool's west column as its goal.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-DONE = 1
         MOVE 0 TO EN-PATH-TICKS(WS-S)
         MOVE WS-I TO CW-TIME
         CALL "STRIDER-TICK" USING WS-S WS-HX WS-HZ WS-WALK
         COMPUTE WS-LX = WS-X0 + 4
         IF EN-PATH-TICKS(WS-S) >= 99 AND EN-DEST-X(WS-S) = WS-LX
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     MOVE "covB 21 5.7 a strider out of lava goes for the lava pool (goal about 100 ticks, west column)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A rider with an empty hand cannot steer it with a stick.
     MOVE WS-S TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 7 TO WS-DONE
     CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     MOVE "covB 21 5.7 an empty hand does not steer the strider" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-STRIDER.
 COPY CORETEST.
 COPY MOBSPTEST.
