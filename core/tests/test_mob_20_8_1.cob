*> Implementation test (002-lane-mobsfull-h5; docs/protocol/20 section 8.1 Enderman): the row (27), the gaze test, the random and towards-teleport
*> destinations, randomTeleport onto a floor, the 64 attempts, and the stare aggro through STDMOB-AGGRO.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-8-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG VALUE 0.
 01 WS-STARED              BINARY-LONG.
 01 WS-DIS                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 5.
 01 WS-FLOORY              BINARY-LONG VALUE 100.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-CEILY               BINARY-LONG VALUE 102.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:enderman" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE "acceptance US15 20§8.1 Enderman: the enderman is row 27" TO WS-CASE
     MOVE 27 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-M
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: 40 health" TO WS-CASE
     MOVE 40 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: attack 7, follow range 64, stare-only target" TO WS-CASE
     MOVE 7064 TO WS-EXP
     COMPUTE WS-OBS = SM-ATTACK(WS-M) * 1000 + SM-FOLLOW(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: natural spawn rule 2 (monster rule in the dark)" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE SM-SPAWN(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Gaze: straight at it is staring; 5.7 degrees off at 10 blocks is not; a carved pumpkin hides it; a zero view or zero distance is not.
     MOVE 0 TO WS-DIS
     MOVE 0 TO WS-VX
     MOVE 0 TO WS-VY
     MOVE 10 TO WS-VZ
     MOVE 0 TO WS-WX
     MOVE 0 TO WS-WY
     MOVE 10 TO WS-WZ
     CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DIS WS-STARED
     MOVE "acceptance US15 20§8.1 Enderman: looking straight at it is a stare" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-STARED
     MOVE 1 TO WS-VX
     CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DIS WS-STARED
     MOVE "acceptance US15 20§8.1 Enderman: an angle of 5.7 degrees at 10 blocks is no stare" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-STARED
     MOVE 0 TO WS-VX
     MOVE 1 TO WS-DIS
     CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DIS WS-STARED
     MOVE "acceptance US15 20§8.1 Enderman: a carved pumpkin hides the stare" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-STARED
     MOVE 0 TO WS-DIS
     MOVE 0 TO WS-VZ
     CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DIS WS-STARED
     MOVE "acceptance US15 20§8.1 Enderman: a zero view vector is no stare" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-STARED
*>   Random destination bounds: x and z within 32, y within -32 to 31.
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-ENDER-DEST-RANDOM" USING XR-STATE WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ
         IF WS-DX < -32 OR WS-DX > 32 OR WS-DZ < -32 OR WS-DZ > 32 OR WS-DY < 32 OR WS-DY > 95
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman: random teleport destinations stay in the 64 block box" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-BAD
*>   Towards an entity 10 blocks east (eye y level): 16 blocks east of the enderman, jittered by 4.
     MOVE 0 TO WS-BAD
     MOVE 10 TO WS-A
     MOVE 64.5 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-ENDER-DEST-TOWARD" USING XR-STATE WS-X WS-Y WS-Z WS-A WS-B WS-EZ WS-DX WS-DY WS-DZ
         IF WS-DX < 12 OR WS-DX > 20 OR WS-DY < 56 OR WS-DY > 71 OR WS-DZ < -4 OR WS-DZ > 4
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman: the towards destination is 16 blocks towards the entity, jittered" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-BAD
*>   Zero distance: the direction is the zero vector and the draws alone place it.
     MOVE WS-X TO WS-EX
     MOVE WS-Y TO WS-EY
     MOVE WS-Z TO WS-EZ
     CALL "STDMOB-ENDER-DEST-TOWARD" USING XR-STATE WS-X WS-Y WS-Z WS-EX WS-EY WS-EZ WS-DX WS-DY WS-DZ
     MOVE "acceptance US15 20§8.1 Enderman: towards its own place gives the jitter box" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-DX >= -4 AND WS-DX <= 4
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   randomTeleport onto a stone floor 100 high, destination high above it.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) + 10
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + 10
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FLOORY WS-KIND
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     COMPUTE WS-DX = WS-FX + 2.5
     MOVE 102 TO WS-DY
     COMPUTE WS-DZ = WS-FZ + 2.5
     CALL "STDMOB-ENDER-TELEPORT" USING WS-ROW WS-DX WS-DY WS-DZ WS-OK
     MOVE "acceptance US15 20§8.1 Enderman: it teleports down onto the floor" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
     MOVE "acceptance US15 20§8.1 Enderman: it stands on the floor block, 1 above the top" TO WS-CASE
     MOVE 101 TO WS-EXP
     COMPUTE WS-OBS = EN-Y(WS-ROW)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: it stands at the centre of the column" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-X(WS-ROW) = WS-FX + 2.5 AND EN-Z(WS-ROW) = WS-FZ + 2.5
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A ceiling over the floor (a block in the head cell) refuses the spot.
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-CEILY WS-KIND
     MOVE 101 TO WS-DY
     COMPUTE WS-DX = WS-FX + 1.5
     CALL "STDMOB-ENDER-TELEPORT" USING WS-ROW WS-DX WS-DY WS-DZ WS-OK
     MOVE "acceptance US15 20§8.1 Enderman: a block in the head cell refuses" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
*>   A destination too low: the walk reaches the world bottom (nothing solid below it fails or lands) without error.
     MOVE -2000 TO WS-DY
     CALL "STDMOB-ENDER-TELEPORT" USING WS-ROW WS-DX WS-DY WS-DZ WS-OK
     MOVE "acceptance US15 20§8.1 Enderman: a destination below the world refuses" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
*>   Up to 64 random attempts: the call ends with ok 0 or 1 and the row stays used.
     MOVE 1 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-ENDER-TRY" USING XR-STATE WS-ROW WS-OK
     MOVE "acceptance US15 20§8.1 Enderman: repeated random teleports end with a flag" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-OK = 0 OR WS-OK = 1
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Aggro: a player looking at the enderman 10 blocks away makes it the target; looking away does not.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-DX = WS-X + 10
     MOVE WS-Y TO WS-DY
     MOVE WS-Z TO WS-DZ
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-DX WS-DY WS-DZ WS-YAW WS-ROW
     MOVE 270 TO PL-YAW(WS-PLAYER)
     MOVE 90 TO PL-PITCH(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-ROW WS-M
     MOVE "acceptance US15 20§8.1 Enderman: a player looking down does not anger it" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -5.3 TO PL-PITCH(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-ROW WS-M
     MOVE "acceptance US15 20§8.1 Enderman: a player staring at it becomes its target" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: the target change time restarts" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-ENDER-TICKS(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 90 TO PL-PITCH(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-ROW WS-M
     MOVE "acceptance US15 20§8.1 Enderman: it keeps its target after the player looks away" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 Enderman: the change time counts up" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-ENDER-TICKS(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-AGGRO" USING WS-ROW WS-M
     MOVE "acceptance US15 20§8.1 Enderman: the target is dropped when the player turns creative" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-ROW
     GOBACK.
 END PROGRAM TEST-MOB-20-8-1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
