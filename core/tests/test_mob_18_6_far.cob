*> Bug lane bugflatspawn (operator report on try16: "hostile mobs aren't spawning in my super flat world at night"; docs/protocol/18-mob-framework.md section 6.11,
*> 6.1 step 1, 6.3): Entity.checkDespawn runs for every mob each tick, before the entity-ticking range test, "so mobs far from players are still despawn-checked each
*> tick". MOBS-TICK kept a mob more than MOB-ACTIVE-RANGE (64) blocks from every player out of its list altogether, so a hostile mob 65 to 128 blocks away never despawned at random
*> and one beyond 128 never despawned at all; the global cap of the monster category (70 x chunks / 289) counts every such mob, so the 70 hostile mobs of one night (spawned 24
*> to 128 blocks from the player, most beyond 64) filled the cap for good and no hostile mob spawned at the next night, or after the player went elsewhere.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-FAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY MOBSPAWN.
 COPY BRWORLD.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-BEYOND             BINARY-LONG.
 01 WS-INSIDE             BINARY-LONG.
 01 WS-NEAR               BINARY-LONG.
 01 WS-ID-INSIDE          BINARY-LONG.
 01 WS-ONE                BINARY-LONG VALUE 1.
 01 WS-HUNDRED            BINARY-LONG VALUE 100.
 01 WS-ROUND              BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   Creative: nothing hurts the player, and the natural spawner never stops for lack of one.
     MOVE 1 TO PL-MODE(WS-PLAYER)
*>   Daylight and a stopped clock are not needed: the mobs are placed by hand.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X = PL-X(WS-PLAYER) + 200
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BEYOND
     COMPUTE WS-X = PL-X(WS-PLAYER) + 100
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-INSIDE
     MOVE EN-ID(WS-INSIDE) TO WS-ID-INSIDE
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEAR
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance 18§6.11 mobs far away are still despawn-checked: a zombie 200 blocks from the only player is removed on the next tick" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-USED(WS-BEYOND)
     PERFORM CHECK-N
     MOVE "acceptance 18§6.11 a zombie 100 blocks away (inside 128, outside the 64 of the entity range) has not despawned after one tick" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = EN-USED(WS-INSIDE)
     PERFORM CHECK-N
*>   The random despawn (noActionTime above 600, nextInt(800) = 0, farther than 32 blocks) reaches the zombie 100 blocks away: after 6000 ticks (P of surviving = 0.1 percent) it is gone.
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 60
         CALL "TEST-TICKS-ANSWERED" USING WS-HUNDRED
     END-PERFORM
     MOVE 0 TO WS-O
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-ID(WS-ROW) = WS-ID-INSIDE
             MOVE 1 TO WS-O
         END-IF
     END-PERFORM
     MOVE "acceptance 18§6.11 a zombie 100 blocks from the player despawns at random within 6000 ticks (it was never despawn-checked beyond 64 blocks)" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-FAR.
 COPY CORETEST.
 COPY MOBSPTEST.
