*> Implementation test of mob movement (core/src/mobs.cob MOBS-TICK; tasks T531; standin-content
*> §12.2 physics, §12.3 wander; 09 §3.3 Mobs rows): a wandering mob decides on ticks with Time mod
*> 80 = 0 with r = H(floor(x), floor(y), floor(z), Time) (§1.4.1): r mod 3 = 0 stands still,
*> otherwise yaw ((r div 3) mod 8) x 45 and the wander speed along it until the next decision; a
*> new mob stands still until its first decision. Physics: vy <- (vy - 0.05) x 0.96 and the move
*> along Y, then X and Z, blocked by solid cells; a blocked horizontal move on the ground steps up
*> 1 block when the box fits there. Viewers get Move Entity Pos (0x36), or Pos Rot (0x37) and Rotate
*> Head (0x55) when the yaw changed, after each tick in which the mob moved or turned; nothing when
*> it did not. A mob whose chunk is not loaded is not processed.
*> Decisions were computed from the §1.4.1 hash at Time 16080: (9, 55, 8) r mod 3 = 1, yaw 90;
*> (12, 56, 9) r mod 3 = 1, yaw 180; (11, 56, 8) r mod 3 = 0. Terrain (§5.2): column (9, 8) turf at
*> 54, the marker pillar of chunk (0, 0) at (8, 55 to 59, 8), column (12, 8) top 55, column (11, 8)
*> top 55. The world is at night with hostile mobs off, so no mob spawns (§12.4), except in the
*> last case (abends, hostile mobs on, a single tick); Alice (creative unless set otherwise) stands
*> at the spawn point and sees every mob here.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-MOVEMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ETIDS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG VALUE 12.
 01 WS-BY                  BINARY-LONG VALUE 56.
 01 WS-BZ                  BINARY-LONG VALUE 8.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-R1                  PIC -(5)9.999.
 01 WS-R2                  PIC -(5)9.999.
 01 WS-R3                  PIC -(5)9.999.
 01 WS-R4                  PIC -(5)9.999.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS

     MOVE "test mob movement given a new sodgrazer when ticks pass before its first decision then "
         & "it stands still and nothing is sent" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 9.5 TO WS-X
     MOVE 55 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 16070 TO CW-TIME
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "| 9.500 55.000 8.500 yaw 0 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given the decision tick (Time 16080, r mod 3 = 1, yaw 90) then the "
         & "sodgrazer turns to yaw 90 and walks 0.05 towards -X, sent as Move Entity Pos Rot and "
         & "Rotate Head" TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "55 85 | 9.450 55.000 8.500 yaw 90 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given the marker pillar (two or more blocks high) in its way when it "
         & "walks into it then it is blocked, cannot step up, and nothing is sent" TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "| 9.450 55.000 8.500 yaw 90 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given a decision with r mod 3 = 0 (column (11, 8)) then the "
         & "sodgrazer stands still" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 11.5 TO WS-X
     MOVE 56 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 16079 TO CW-TIME
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "| 11.500 56.000 8.500 yaw 0 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given yaw 180 (walking towards -Z) and a one-block step in its way "
         & "when it walks into it then it steps up onto it (y + 1), sent as Move Entity Pos"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 12.5 TO WS-X
     MOVE 56 TO WS-Y
     MOVE 9.5 TO WS-Z
     MOVE 180 TO WS-YAW
     PERFORM ADD-MOB
     MOVE 0 TO WS-YAW
     MOVE 16079 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "54 | 12.500 57.000 9.400 yaw 180 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given the mob stepped up when the next tick passes then it stands on "
         & "the step (vertical velocity 0) and walks on" TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "54 | 12.500 57.000 9.350 yaw 180 ground 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given a sodgrazer 4 blocks above the ground when a tick passes then "
         & "vy becomes (0 - 0.05) x 0.96 = -0.048 and it falls by that much" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 11.5 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 16000 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     PERFORM DESCRIBE-VY
     MOVE "54 | 11.500 59.952 8.500 yaw 0 ground 0 vy -0.048" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given the falling sodgrazer when it reaches the ground then it rests "
         & "on top of the solid cell (y 56) with vertical velocity 0" TO TL-CASE
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM DRAIN-IDS
     MOVE SPACES TO TL-OBSERVED
     PERFORM DESCRIBE
     PERFORM DESCRIBE-VY
     MOVE "| 11.500 56.000 8.500 yaw 0 ground 1 vy 0.000" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given a mob in a chunk that is not loaded when a tick passes then it "
         & "is not processed (it does not fall)" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 1000.5 TO WS-X
     MOVE 80 TO WS-Y
     MOVE 1000.5 TO WS-Z
     PERFORM ADD-MOB
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DRAIN-IDS
     PERFORM DESCRIBE
     MOVE "| 1000.500 80.000 1000.500 yaw 0 ground 0" TO TL-EXPECTED
     PERFORM CHECK-TEXT

     MOVE "test mob movement given a mob with a hurt cooldown of 5 when a tick passes then it is "
         & "4 (§10.2)" TO TL-CASE
     MOVE 11.5 TO WS-X
     MOVE 56 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 5 TO EN-HURT(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-HURT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob movement given two abends in reach of survival Alice, the lower tracker row "
         & "holding the higher entity id, when a tick passes then they act in entity id order: "
         & "entity 3 hits her (source 4), the other hit is ignored" TO TL-CASE
     MOVE 1 TO CS-HOSTILE-MOBS
     PERFORM OPEN-AND-JOIN
     MOVE 0 TO PL-MODE(CN-PLAYER(WS-ALICE))
     MOVE 3 TO WS-TYPE
     MOVE 4.5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 9.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE WS-ROW TO WS-FIRST
     PERFORM ADD-MOB
     CALL "ENTITY-REMOVE" USING WS-FIRST
     PERFORM ADD-MOB
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "damage 1 type 28 source 4 | hurt 1 | health 27 food 24" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     STOP RUN.

*> Opens the world at night with hostile mobs off; creative Alice joins at the spawn point and is
*> drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT.

*> A sodgrazer at (WS-X, WS-Y, WS-Z) with yaw WS-YAW; Alice is drained of its Add Entity.
 ADD-MOB.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT.

*> Alice's drained packets (TEST-DRAIN-ENTITIES: Move Entity and Rotate Head by id, Set Time left
*> out) go to TL-OBSERVED.
 DRAIN-IDS.
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED.

*> Appends " | x y z yaw <yaw> ground <on-ground>" of the mob (WS-ROW) to TL-OBSERVED.
 DESCRIBE.
     COMPUTE WS-R1 ROUNDED = EN-X(WS-ROW)
     COMPUTE WS-R2 ROUNDED = EN-Y(WS-ROW)
     COMPUTE WS-R3 ROUNDED = EN-Z(WS-ROW)
     MOVE EN-YAW(WS-ROW) TO WS-E1
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E2
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " | " FUNCTION TRIM(WS-R1) " " FUNCTION TRIM(WS-R2) " "
         FUNCTION TRIM(WS-R3) " yaw " FUNCTION TRIM(WS-E1) " ground " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED.

*> Appends " vy <vertical velocity>" of the mob to TL-OBSERVED.
 DESCRIBE-VY.
     COMPUTE WS-R4 ROUNDED = EN-VY(WS-ROW)
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " vy " FUNCTION TRIM(WS-R4) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 CHECK-TEXT.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-MOVEMENT.

 COPY CORETEST.
