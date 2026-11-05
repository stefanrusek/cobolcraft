*> Acceptance test, US9-2 and US9-3 core half (spec US9 scenarios 2 and 3; tasks T533; standin-content
*> §12.1, §12.3, §10.2, §10.3; 09 §3.3 Health rows): an abend takes as its target the nearest alive
*> survival player of its dimension within 12.0 blocks (ties: the earliest-entering player), faces
*> it (yaw = atan2(-dx, dz)), walks towards it at 0.12 blocks per tick while the horizontal distance
*> is above 1.0, and, within 1.75 blocks with its attack cooldown at 0, does 3 damage
*> (cobolcraft:mob_attack, 28; source id = its entity id + 1) and waits 30 ticks; a sodgrazer never
*> attacks. Terrain (§5.2): columns x = 4, z = 0 to 25 all have their top at 53, so feet stand at
*> 54 and the ground is flat along z. Alice (entity 1) stands at (4.5, 54, 8.5); the abend (entity 2,
*> or 3 with Bobby) starts 6 blocks south of her at (4.5, 54, 14.5): it reaches 1.75 after 36 moves
*> (6 - 36 x 0.12 = 1.68), so the 37th tick attacks; it stops after 42 moves at 6 - 5.04 = 0.96.
*> The test runs at night (Time 16001) in windows shorter than 99 ticks, so no spawn tick (Time mod
*> 100 = 0) and no wander decision of a targeted abend interferes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-HOSTILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ENTITYTYPES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-X                   FLOAT-LONG VALUE 4.5.
 01 WS-Y                   FLOAT-LONG VALUE 54.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-R1                  PIC -(5)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE

     MOVE "acceptance US9-2 given an abend 6 blocks from survival Alice (within the notice range "
         & "of 12.0) when 36 ticks pass then it has walked 36 x 0.12 towards her, faces her (yaw "
         & "180) and has not attacked yet" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-ABEND TO WS-TYPE
     MOVE 14.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 36 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 10.18 yaw 180 target 1 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given the abend 1.68 blocks from Alice (within its reach of 1.75) when "
         & "the next tick passes then she takes 3 damage (mob_attack, source 2 + 1) and sees it"
         TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 28 source 3 | hurt 1 | health 27 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given the abend attacked when 29 ticks pass then it does not attack "
         & "again (cooldown 30) and has stopped within 1.0 of her (z 9.46)" TO TL-CASE
     MOVE 29 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 9.46 yaw 180 target 1 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given the cooldown of 30 ticks is over when the 30th tick passes then "
         & "the abend attacks again" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 28 source 3 | hurt 1 | health 24 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-3 given a sodgrazer next to survival Alice when 98 ticks pass then it "
         & "never attacks her" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 9.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 98 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given survival Alice 12.5 blocks from an abend (beyond the notice "
         & "range) when a tick passes then it does not notice her" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-ABEND TO WS-TYPE
     MOVE 21 TO WS-Z
     PERFORM ADD-MOB
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 21.00 yaw 0 target 0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given survival Alice 11.9 blocks from an abend then it notices her"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 20.4 TO WS-Z
     PERFORM ADD-MOB
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 20.28 yaw 180 target 1 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given a creative player within the notice range then the abend does "
         & "not take her as its target" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 1 TO PL-MODE(CN-PLAYER(WS-ALICE))
     MOVE 14.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 14.50 yaw 0 target 0 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given Bobby 3 blocks and Alice 6 blocks from an abend then it takes "
         & "the nearest, Bobby, as its target" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM JOIN-BOB
     MOVE 17.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     MOVE 14.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 14.62 yaw 0 target 2 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-2 given Alice and Bobby both 6 blocks from an abend then it takes the "
         & "earlier-entering player, Alice" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM JOIN-BOB
     MOVE 20.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     MOVE 14.5 TO WS-Z
     PERFORM ADD-MOB
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "z 14.38 yaw 180 target 1 |" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world at night (Time 16001); survival Alice joins and stands at (4.5, 54, 8.5) facing
*> south; she is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 8.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.

*> Survival Bobby joins (entity 2) and is drained.
 JOIN-BOB.
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT.

*> A mob of WS-TYPE at (4.5, 54, WS-Z) with yaw 0.
 ADD-MOB.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.

*> WS-TEXT becomes "z <z> yaw <yaw> target <target entity id> | " followed by its old content.
 DESCRIBE-MOB.
     COMPUTE WS-R1 ROUNDED = EN-Z(WS-ROW)
     MOVE EN-YAW(WS-ROW) TO WS-E1
     MOVE EN-TARGET-ID(WS-ROW) TO WS-E2
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING "z " FUNCTION TRIM(WS-R1) " yaw " FUNCTION TRIM(WS-E1) " target "
         FUNCTION TRIM(WS-E2) " | " FUNCTION TRIM(TL-OBSERVED) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-HOSTILE.

 COPY CORETEST.
