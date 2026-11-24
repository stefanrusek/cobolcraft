*> Acceptance test, US9-1 core half (spec US9 scenario 1; tasks T529; standin-content §12.4, §4.8
*> night, §5.2 terrain and light; 09 §3.3 Mobs rows): on ticks with Time mod 100 = 0, each alive
*> player of a dimension, in entering order, may cause one mob to spawn at the column chosen by
*> r = H(dimension index, floor(x), floor(z), Time) (§1.4.1), of the type the dimension's rule
*> names (cobolcraft:main: a sodgrazer by day on turf, an abend at night in block light 5 or less),
*> unless the column is nearer than 8 on both axes, a player is within 8.0 blocks of the spawn
*> position, or the dimension already holds its cap of that type; viewers are sent Add Entity.
*> Expected columns were computed from the §1.4.1 hash and the §5.2 height formula: Alice at the
*> spawn point (4.5, 54, 8.5) gives, at Time 100, dx 19, dz 11 (column (23, 19), turf at 56, yaw
*> 180); at 400 dx -2, dz -5 (too near); at 800 column (-11, 4), grit at 49; at 300 column (2, 17)
*> (spawn position (2.5, 53, 17.5)); at 16100 column (-6, 8), turf at 51, yaw 315, far from any
*> marker glowtube (block light 0). Bobby at (2.5, 53, 15.5) gives at 300 column (-18, 29), grit at
*> 49; Carol at (-14.5, 50, 10.5) gives at 100 column (-1, 15), turf at 52. The cobolcraft:subroutine rule (§15.4) is exercised by test_mob_spawn_extra.cob; only
*> cobolcraft:main is exercised here. Alice and Bobby are creative, so a new
*> abend has no target and stands still.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-SPAWNING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ETIDS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE

     MOVE "acceptance US9-1 given cobolcraft:main by day and Alice at the spawn point when Time "
         & "reaches 100 then a sodgrazer spawns on the turf of column (23, 19) with yaw 180 and "
         & "Alice is sent it" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE "1(2,2@23.50,57.00,19.50)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US9-1 the spawned sodgrazer has full health (8) and the yaw of the rule (180)"
         TO TL-CASE
     PERFORM DESCRIBE-MOB-2
     MOVE "type 2 health 8 yaw 180" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given Time 99 when one tick passes to 100 but only every 100th tick "
         & "spawns then nothing spawns at Time 101" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 100 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given the chosen column is nearer than 8 on both axes (Time 400: dx "
         & "-2, dz -5) then nothing spawns" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 400 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given cobolcraft:main by day and a column topped with grit (Time 800) "
         & "then no sodgrazer spawns (turf only)" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 800 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given Bobby stands 2 blocks from the spawn position chosen for Alice "
         & "(Time 300) then nothing spawns for her (no player within 8.0), nor for him (grit)"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 2.5 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 15.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 300 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given Alice alone at Time 300 then the sodgrazer spawns at (2.5, 53, "
         & "17.5), 9.3 blocks from her" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 300 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE "1(2,2@2.50,53.00,17.50)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given cobolcraft:main already holds 12 sodgrazers when a sodgrazer "
         & "would spawn (Time 100) then none spawns" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-SODGRAZER TO WS-TYPE
     PERFORM 12 TIMES
         PERFORM ADD-RESTING-MOB
     END-PERFORM
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given cobolcraft:main at night (Time 16100) and a column in block "
         & "light 0 then an abend spawns at (-5.5, 52, 8.5) on the turf where a sodgrazer would "
         & "by day, with yaw 315" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 16100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE "1(2,3@-5.50,52.00,8.50)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US9-1 the spawned abend has full health (12) and yaw 315" TO TL-CASE
     PERFORM DESCRIBE-MOB-2
     MOVE "type 3 health 12 yaw 315" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given cobolcraft:main at night and a lit glowtube next to the chosen "
         & "column (block light 14 at (-6, 52, 8)) then no abend spawns (light above 5)"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE -5 TO WS-BX
     MOVE 52 TO WS-BY
     MOVE 8 TO WS-BZ
     MOVE 13 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 16100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given cobolcraft:main already holds 8 abends when an abend would "
         & "spawn (Time 16100) then none spawns" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-ABEND TO WS-TYPE
     PERFORM 8 TIMES
         PERFORM ADD-RESTING-MOB
     END-PERFORM
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE 16100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US9-1 given 11 sodgrazers and Bobby entering before Carol (who holds the "
         & "lower player row) when both could cause one (Time 100) then only Bobby's spawns, "
         & "reaching the cap of 12" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE -14.5 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 10.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     MOVE ET-SODGRAZER TO WS-TYPE
     PERFORM 11 TIMES
         PERFORM ADD-RESTING-MOB
     END-PERFORM
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 99 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE "1(15,2@23.50,57.00,19.50)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given the chosen column's chunk is not loaded (Alice's position set "
         & "far away, at (1000.5, 54, 1000.5), without moving her view) then nothing spawns"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 1000.5 TO PL-X(CN-PLAYER(WS-ALICE)) PL-Z(CN-PLAYER(WS-ALICE))
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given the chosen column (23, 19) holds a block at y 254, so top + 2 "
         & "is outside the height range, then nothing spawns" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 23 TO WS-BX
     MOVE 254 TO WS-BY
     MOVE 19 TO WS-BZ
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-TICK
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world; creative Alice joins at the spawn point and is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT.

*> CW-TIME holds the wanted Time: one tick is run from the Time before it; Alice is drained.
 SPAWN-TICK.
     SUBTRACT 1 FROM CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT.

*> A mob of WS-TYPE resting on the grit of column (-20, -20) (surface 48, feet at 49), in a loaded
*> chunk.
 ADD-RESTING-MOB.
     MOVE -19.5 TO WS-X
     MOVE -19.5 TO WS-Z
     MOVE 49 TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.

 DESCRIBE-MOB-2.
     MOVE 2 TO WS-I
     CALL "TEST-FIND-ENTITY" USING WS-I WS-ROW
     MOVE "no entity 2" TO WS-TEXT
     IF WS-ROW = 0
         EXIT PARAGRAPH
     END-IF
     MOVE EN-TYPE(WS-ROW) TO WS-E1
     MOVE EN-HEALTH(WS-ROW) TO WS-E2
     MOVE EN-YAW(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "type " FUNCTION TRIM(WS-E1) " health " FUNCTION TRIM(WS-E2) " yaw "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-SPAWNING.

 COPY CORETEST.
