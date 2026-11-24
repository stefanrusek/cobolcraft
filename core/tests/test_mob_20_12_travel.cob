*> Acceptance test (lane p49r; docs/protocol/20 section 12.1): the phantom's flying travel. The move control blends the velocity (v += (wanted - v) * 0.2), then the
*> travel moves the phantom by v and multiplies v by 0.91 in air (0.8 in water, 0.5 in lava); the 0.2 of `travelFlying` is an input acceleration a phantom never has.
*> The expected displacements are the document's worked case (a constant wanted velocity of 1.8 along +x from rest: 0.36, 0.6221, 0.8129, 0.9518, ... 1.3235 at
*> the steady state), computed independently in Python from v' = v + 0.2 (1.8 - v), displacement v', v = 0.91 v'.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-12-TRAVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DISP                FLOAT-LONG.
 01 WS-TICK                PIC 9.
 01 WS-EXPECT.
    05 WS-E                BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:phantom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 20
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
*>   A cube of air around the flight cell.
     PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 3
         PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-I = WS-BX + WS-DX
                 COMPUTE WS-STATE = WS-BY + WS-DY
                 COMPUTE WS-X0 = WS-BZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-STATE WS-X0 WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 3600 TO WS-E(1)
     MOVE 6221 TO WS-E(2)
     MOVE 8129 TO WS-E(3)
     MOVE 9518 TO WS-E(4)
*>   Air: a target 100000 blocks along +x, yaw -90 (heading along +x), speed 1.8: the wanted velocity is the constant 1.8 along +x.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE -90 TO EN-YAW(WS-MOB)
     MOVE 1.8 TO EN-PH-SPEED(WS-MOB)
     MOVE 0 TO EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     COMPUTE EN-PH-TX(WS-MOB) = WS-X + 100000
     MOVE WS-Y TO EN-PH-TY(WS-MOB)
     MOVE WS-Z TO EN-PH-TZ(WS-MOB)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE EN-X(WS-MOB) TO WS-X0
         CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
         CALL "STDMOB-PHANTOM-TRAVEL" USING WS-MOB
         COMPUTE WS-DISP = EN-X(WS-MOB) - WS-X0
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-TICK
         STRING "acceptance US15 20§12.1 Phantom in air: the displacement of tick " DELIMITED BY SIZE WS-TICK DELIMITED BY SIZE
             " follows v' = v + 0.2 (1.8 - v), v = 0.91 v' (ten thousandths)" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E(WS-I) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = WS-DISP * 10000
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The steady state after 100 ticks: displacement 0.7353 x 1.8 = 1.3235 per tick, 1.2044 of velocity left after the damping.
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 100
         CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
         MOVE EN-X(WS-MOB) TO WS-X0
         CALL "STDMOB-PHANTOM-TRAVEL" USING WS-MOB
     END-PERFORM
     COMPUTE WS-DISP = EN-X(WS-MOB) - WS-X0
     MOVE "acceptance US15 20§12.1 Phantom in air: the steady displacement is 1.3235 a tick (ten thousandths)" TO TL-CASE
     MOVE 13235 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-DISP * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12.1 Phantom in air: the velocity left after the damping is 1.2044 (ten thousandths)" TO TL-CASE
     MOVE 12044 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   Water multiplies the velocity by 0.8 and lava by 0.5 (the phantom stands in the fluid cell).
     COMPUTE WS-STATE = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-STATE WS-BZ WS-WATER
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-VX(WS-MOB)
     MOVE 0 TO EN-VY(WS-MOB) EN-VZ(WS-MOB)
     CALL "STDMOB-PHANTOM-TRAVEL" USING WS-MOB
     MOVE "acceptance US15 20§12.1 Phantom in water: the velocity is multiplied by 0.8 (ten thousandths)" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-STATE WS-BZ WS-LAVA
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-VX(WS-MOB)
     MOVE 0 TO EN-VY(WS-MOB) EN-VZ(WS-MOB)
     CALL "STDMOB-PHANTOM-TRAVEL" USING WS-MOB
     MOVE "acceptance US15 20§12.1 Phantom in lava: the velocity is multiplied by 0.5 (ten thousandths)" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.
 END PROGRAM TEST-MOB-20-12-TRAVEL.
 COPY CORETEST.
 COPY MOBSPTEST.
